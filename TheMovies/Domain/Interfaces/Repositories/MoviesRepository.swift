//
//  MoviesRepository.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/19/21.
//

import Foundation

protocol MoviesRepository{
    @discardableResult
    func fetchMoviesList(query: MovieQuery, page: Int,
                         cached: @escaping (MoviesPage) -> Void,
                         completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable?
}
