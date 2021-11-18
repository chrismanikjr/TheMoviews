//
//  Endpoint.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/18/21.
//

import Foundation

public enum HTTPMethodType: String{
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

public enum BodyEncoding{
    case jsonSerializationData
    case stringEncodingAscii
}

public protocol Requestable {
    var path: String { get }
    var isFullPath: Bool { get }
    var method: HTTPMethodType { get }
    var headerParams: [String: String] { get }
    var queryParamsEncodable: Encodable? { get }
    var queryParams: [String: Any] { get }
    var bodyParamsEncodable: Encodable? { get }
    var bodyParams: [String: Any] { get }
    var bodyEncoding: BodyEncoding { get }
    
    func urlRequest(with networkConfig: NetworkConfig) throws -> URLRequest
}

public protocol ResponseRequestable: Requestable {
    associatedtype Response
    var responseDecoder: ResponseDecoder { get }
}


public class Endpoint<R>: ResponseRequestable {
    public typealias Response = R
    
    public var path: String
    public var isFullPath: Bool
    public var method: HTTPMethodType
    public var headerParams: [String : String]
    public var queryParamsEncodable: Encodable?
    public var queryParams: [String : Any]
    public var bodyParamsEncodable: Encodable?
    public var bodyParams: [String : Any]
    public var bodyEncoding: BodyEncoding
    public var responseDecoder: ResponseDecoder
    
    init(path: String,
         isFullPath: Bool = false,
         method: HTTPMethodType,
         headerParams: [String: String] = [:],
         queryParamsEncodable: Encodable? = nil,
         queryParams: [String : Any] = [:],
         bodyParamsEncodable: Encodable? = nil,
         bodyParams: [String : Any] = [:],
         bodyEncoding: BodyEncoding = .jsonSerializationData,
         responseDecoder: ResponseDecoder = JSONResponseDecoder()){
        self.path = path
        self.isFullPath = isFullPath
        self.method = method
        self.headerParams = headerParams
        self.queryParams = queryParams
        self.queryParamsEncodable = queryParamsEncodable
        self.bodyParams = bodyParams
        self.bodyParamsEncodable = bodyParamsEncodable
        self.bodyEncoding = bodyEncoding
        self.responseDecoder = responseDecoder
    }
}
enum RequestGenerationError: Error{
    case components
}
// MARK: - Extension Requestable

extension Requestable{
    func url(with config: NetworkConfig) throws -> URL{
        let baseURL = config.baseURL.absoluteString.last != "/" ? config.baseURL.absoluteString + "/": config.baseURL.absoluteString
        let endpoint = isFullPath ? path: baseURL.appending(path)
        
        guard var urlComponents = URLComponents(string: endpoint) else {throw RequestGenerationError.components}
        var urlQueryItems = [URLQueryItem]()
        
        let queryParams = try queryParamsEncodable?.toDictionary() ?? self.queryParams
        queryParams.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
        }
        config.queryParams.forEach{
            urlQueryItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems: nil
        guard let url = urlComponents.url else {throw RequestGenerationError.components}
        return url
    }
    
    public func urlRequest(with config: NetworkConfig) throws -> URLRequest{
        let url = try self.url(with: config)
        var urlRequest = URLRequest(url: url)
        var allHeaders: [String: String] = config.headers
        headerParams.forEach{ allHeaders.updateValue($1, forKey: $0)}
        
        let bodyParameters = try bodyParamsEncodable?.toDictionary() ?? self.bodyParams
        if !bodyParameters.isEmpty{
            urlRequest.httpBody = encodeBody(bodyParameters: bodyParameters, bodyEncoding: bodyEncoding)
        }
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = allHeaders
        return urlRequest
    }
    
    private func encodeBody(bodyParameters: [String: Any], bodyEncoding: BodyEncoding) -> Data?{
        switch bodyEncoding {
        case .jsonSerializationData:
            return try? JSONSerialization.data(withJSONObject: bodyParameters)
        case .stringEncodingAscii:
            return bodyParameters.queryString.data(using: String.Encoding.ascii, allowLossyConversion: true)
        }
    }
}

private extension Dictionary{
    var queryString: String{
        return self.map{"\($0.key)=\($0.value)"}.joined(separator: "&").addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
    }
}

private extension Encodable{
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        return jsonData as? [String: Any]
    }
}
