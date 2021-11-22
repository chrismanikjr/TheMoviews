//
//  UseCase.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/19/21.
//

import Foundation

public protocol UseCase{
    @discardableResult
    func start()-> Cancellable?
}
