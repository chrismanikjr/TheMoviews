//
//  MovieQueryUDS+Mapping.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/19/21.
//

import Foundation

struct MovieQueriesListUDS: Codable {
    var list: [MovieQueryUDS]
}

struct MovieQueryUDS: Codable {
    let query: String
}

extension MovieQueryUDS {
    init(movieQuery: MovieQuery) {
        query = movieQuery.query
    }
}

extension MovieQueryUDS {
    func toDomain() -> MovieQuery {
        return .init(query: query)
    }
}
