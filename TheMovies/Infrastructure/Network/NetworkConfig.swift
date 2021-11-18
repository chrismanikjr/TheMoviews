//
//  NetworkConfig.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/19/21.
//

import Foundation

public protocol NetworkConfig{
    var baseURL: URL {get}
    var headers: [String: String] {get}
    var queryParams: [String: String] {get}
}

public struct ApiDataNetworkConfig: NetworkConfig{
    public let baseURL: URL
    public let headers: [String : String]
    public let queryParams: [String : String]
    
    public init(baseURL: URL, headers: [String: String] = [:], queryParams: [String: String] = [:]){
        self.baseURL = baseURL
        self.headers = headers
        self.queryParams = queryParams
    }
}
