//
//  AppConfig.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/18/21.
//

import Foundation

final class AppConfigs{
    lazy var apiKey: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiKey") as? String else{
            fatalError("ApiKey is empty, input ApiKey with value in plist")
        }
        return apiKey
    }()
    lazy var apiBaseURL: String = {
        guard let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "ApiBaseURL") as? String else {
            fatalError("ApiBaseUrl is empty, add ApiBaseUrl with value in plist")
        }
        return apiBaseURL
    }()
    lazy var imageBaseURL: String = {
        guard let imageBaseURL = Bundle.main.object(forInfoDictionaryKey: "ImageBaseURL") as? String else{
            fatalError("ImageBaseUrl is empty, add ApiBaseUrl with value in plist")
        }
        return imageBaseURL
    }()
}
