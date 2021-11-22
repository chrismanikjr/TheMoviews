//
//  MoviesRequestDTO+Mapping.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/19/21.
//

import Foundation

struct MoviesRequestDTO: Encodable {
    let query: String
    let page: Int
}
