//
//  MoviesResponseStorage.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/19/21.
//

import Foundation

protocol MoviesResponseStorage {
    func getResponse(for request: MoviesRequestDTO, completion: @escaping (Result<MoviesResponseDTO?, CoreDataStorageError>) -> Void)
    func save(response: MoviesResponseDTO, for requestDto: MoviesRequestDTO)
}
