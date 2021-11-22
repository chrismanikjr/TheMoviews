//
//  DataTransferService.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/19/21.
//

import Foundation

public enum DataTransferError: Error{
    case noResponse
    case parsing(Error)
    case networkFailure(NetworkError)
    case resolvedNetworkFailure(Error)
}

public protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}


public protocol DataTransferService{
    typealias CompletionHandler<T> = (Result<T, DataTransferError>) -> Void
    
    @discardableResult
    func request<T: Decodable, E: ResponseRequestable>(with endpoint: E,
                                                       completion: @escaping CompletionHandler<T>) -> NetworkCancellable? where E.Response == T
    
    @discardableResult
    func request<E: ResponseRequestable>(with endpoint: E,
                                         completion: @escaping CompletionHandler<Void>) -> NetworkCancellable? where E.Response == Void

}
public protocol DataTransferErrorResolver{
    func resolve(error: NetworkError) -> Error
}
public protocol DataTransferErrorLogger {
    func log(error: Error)
}

public final class DefaultDataTransferService{
    private let networkService: NetworkService
    private let errorResolver: DataTransferErrorResolver
    private let errorLogger: DataTransferErrorLogger
    
    public init(with networkService: NetworkService, errorResolver: DataTransferErrorResolver = DefaultDataTransferErrorResolver(),
                errorLogger: DataTransferErrorLogger = DefaultDataTransferErrorLogger()){
        self.networkService = networkService
        self.errorLogger = errorLogger
        self.errorResolver = errorResolver
    }
}
// MARK: - Logger
public final class DefaultDataTransferErrorLogger: DataTransferErrorLogger{
    public init() { }
    
    public func log(error: Error) {
        printIfDebug("-----------")
        printIfDebug("\(error)")
    }
}

// MARK: - Resolver
public class DefaultDataTransferErrorResolver: DataTransferErrorResolver{
    public init() { }
    
    public func resolve(error: NetworkError) -> Error {
        return error
    }
}

// MARK: - Response Decoders
public class JSONResponseDecoder: ResponseDecoder {
    private let jsonDecoder = JSONDecoder()
    public init() { }
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
}

public class RawDataResponseDecoder: ResponseDecoder{
    public init() { }
    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }
    
    public func decode<T:Decodable>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T{
            return data
        }else {
            let context = DecodingError.Context(codingPath: [CodingKeys.default], debugDescription: "Desired Data")
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }
}

// MARK: - Enxtension
extension DefaultDataTransferService: DataTransferService{
    private func decode<T: Decodable>(data: Data?, decoder: ResponseDecoder) -> Result<T, DataTransferError> {
        do {
            guard let data = data else { return .failure(.noResponse) }
            let result: T = try decoder.decode(data)
            return .success(result)
        } catch {
            self.errorLogger.log(error: error)
            return .failure(.parsing(error))
        }
    }
    
    private func resolve(networkError error: NetworkError) -> DataTransferError {
        let resolvedError = self.errorResolver.resolve(error: error)
        return resolvedError is NetworkError ? .networkFailure(error) : .resolvedNetworkFailure(resolvedError)
    }
    
    public func request<T, E>(with endpoint: E, completion: @escaping CompletionHandler<T>) -> NetworkCancellable? where T: Decodable, E: ResponseRequestable, T == E.Response {
        return self.networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                let result: Result<T,DataTransferError> = self.decode(data: data, decoder: endpoint.responseDecoder)
                DispatchQueue.main.async {
                    return completion(result)
                }
            case .failure(let error):
                self.errorLogger.log(error: error)
                let error = self.resolve(networkError: error)
                DispatchQueue.main.async {
                    return completion(.failure(error))
                }
            }
        }
    }
    
    public func request<E>(with endpoint: E, completion: @escaping CompletionHandler<Void>) -> NetworkCancellable? where E : ResponseRequestable, E.Response == Void {
        return self.networkService.request(endpoint: endpoint) { result in
            switch result{
            case .success:
                DispatchQueue.main.async {
                    return completion(.success(()))
                }
            case .failure(let error):
                self.errorLogger.log(error: error)
                let error = self.resolve(networkError: error)
                DispatchQueue.main.async {
                    return completion(.failure(error))
                }
            }
            
        }
    }
    
}
extension DataTransferError: ConnectionError {
    public var isInternetConnectionError: Bool {
        guard case let DataTransferError.networkFailure(networkError) = self,
            case .notConnect = networkError else {
                return false
        }
        return true
    }
}
