//
//  SearchMoviesUseCase.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/19/21.
//

import Foundation

struct SearchMoviesUseCaseRequestValue {
    let query: MovieQuery
    let page: Int
}
protocol SearchMoviesUseCase{
    func execute(requestValue: SearchMoviesUseCaseRequestValue,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable?
    
}
final class DefaultSearchMoviesUseCase: SearchMoviesUseCase {

    private let moviesRepository: MoviesRepository
    private let moviesQueriesRepository: MoviesQueriesRepository

    init(moviesRepository: MoviesRepository,
         moviesQueriesRepository: MoviesQueriesRepository) {

        self.moviesRepository = moviesRepository
        self.moviesQueriesRepository = moviesQueriesRepository
    }

    func execute(requestValue: SearchMoviesUseCaseRequestValue,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {

        return moviesRepository.fetchMoviesList(query: requestValue.query,
                                                page: requestValue.page,
                                                cached: cached,
                                                completion: { result in

            if case .success = result {
                self.moviesQueriesRepository.saveRecentQuery(query: requestValue.query) { _ in }
            }

            completion(result)
        })
    }
}
