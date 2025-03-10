////
////  Movie.swift
////  MovieDiary
////
////  Created by Saebyeok Jang on 3/10/25.
////
//
//import Foundation
//
//struct Movie: Codable, Identifiable {
//    let id: Int
//    let title: String
//    let overview: String
//    let posterPath: String?
//    let backdropPath: String?
//    let voteAverage: Double
//    let releaseDate: String?
//    let genreIds: [Int]
//    
//    enum CodingKeys: String, CodingKey {
//        case id, title, overview
//        case posterPath = "poster_path"
//        case backdropPath = "backdrop_path"
//        case voteAverage = "vote_average"
//        case releaseDate = "release_date"
//        case genreIds = "genre_ids"
//    }
//    
//    var posterURL: URL? {
//        guard let posterPath = posterPath else { return nil }
//        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
//    }
//    
//    var daysUntilRelease: String? {
//        guard let releaseDateString = releaseDate else { return nil }
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        guard let releaseDate = dateFormatter.date(from: releaseDateString) else { return nil }
//        
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.day], from: Date(), to: releaseDate)
//        guard let days = components.day else { return nil }
//        
//        if days < 0 {
//            return nil
//        } else if days == 0 {
//            return "오늘 개봉"
//        } else {
//            return "D-\(days)"
//        }
//    }
//}
