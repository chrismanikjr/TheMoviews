//
//  RepoTask.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/19/21.
//

import Foundation

class RepositoryTask: Cancellable {
    var networkTask: NetworkCancellable?
    var isCancelled: Bool = false
    
    func cancel() {
        networkTask?.cancel()
        isCancelled = true
    }
}
