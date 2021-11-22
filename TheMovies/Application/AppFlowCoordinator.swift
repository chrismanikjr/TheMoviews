//
//  AppFlowCoordinator.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/22/21.
//

import UIKit

final class AppFlowCoordinator {

    var navigationController: UINavigationController
    private let appContainer: AppContainer
    
    init(navigationController: UINavigationController,
         appContainer: AppContainer) {
        self.navigationController = navigationController
        self.appContainer = appContainer
    }

    func start() {
        // In App Flow we can check if user needs to login, if yes we would run login flow
        let moviesSceneDIContainer = appContainer.makeMoviesSceneDIContainer()
        let flow = moviesSceneDIContainer.makeMoviesSearchFlowCoordinator(navigationController: navigationController)
        flow.start()
    }
}
