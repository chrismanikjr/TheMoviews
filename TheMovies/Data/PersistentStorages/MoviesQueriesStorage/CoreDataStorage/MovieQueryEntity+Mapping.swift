//
//  MovieQueryEntity+Mapping.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/19/21.
//

import Foundation
import CoreData

extension MovieQueryEntity {
    convenience init(movieQuery: MovieQuery, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        query = movieQuery.query
        createdAt = Date()
    }
}

extension MovieQueryEntity {
    func toDomain() -> MovieQuery {
        return .init(query: query ?? "")
    }
}
