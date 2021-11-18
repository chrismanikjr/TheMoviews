//
//  AppContainer.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/18/21.
//

import Foundation

final class AppContainer {
    lazy var appConfigs = AppConfigs()
    
    // MARK: - Network
    lazy var apiDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfigs.apiBaseURL)!, queryParams: ["api_key" : appConfigs.apiKey, "language": NSLocale.preferredLanguages.first ?? "en"])
        
        let apiDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
    lazy var imageDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfigs.imageBaseURL)!)
        let imagesDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: imagesDataNetwork)
    }()
    
    // MARK: - Container of Scenes
//    func makeMoviesSceneContainer() -> 

}
