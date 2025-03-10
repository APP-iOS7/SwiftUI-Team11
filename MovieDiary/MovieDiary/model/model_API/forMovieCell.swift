//
//  forMovieCell.swift
//  MovieDiary
//
//  Created by 고요한 on 3/10/25.
//

import Foundation

struct ForMovieCell: Identifiable, Codable {
    var id: Int
    var title: String
    var posterPath: String
    var genreIds: [Int]
    var releaseDate: String
}
