//
//  MovieRepository.swift
//  MovieDiary
//
//  Created by Saebyeok Jang on 3/10/25.
//

import Foundation
import Combine

struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

protocol MovieRepositoryProtocol {
    func getMoviesByGenre(genreId: Int) -> AnyPublisher<[Movie], Error>
    func searchMovies(query: String, page: Int) -> AnyPublisher<[Movie], Error>
    func updateMovie(id: Int, rate: Double?, isBookmarked: Bool?, comment: String?) -> AnyPublisher<Void, Error>
}

class MovieRepository: MovieRepositoryProtocol {
    private let apiService: MovieAPIServiceProtocol
    
    init(apiService: MovieAPIServiceProtocol = MovieDiaryAPIService.shared) {
        self.apiService = apiService
    }
    
    func getMoviesByGenre(genreId: Int) -> AnyPublisher<[Movie], Error> {
        return apiService.getMoviesByGenre(genreId: genreId, page: 1)
            .map { response in
                return response.results
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func searchMovies(query: String, page: Int = 1) -> AnyPublisher<[Movie], Error> {
        return apiService.searchMovies(query: query, page: page)
            .map { response in
                return response.results
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func updateMovie(id: Int, rate: Double?, isBookmarked: Bool?, comment: String?) -> AnyPublisher<Void, Error> {
        return apiService.updateMovie(id: id, rate: rate, isBookmarked: isBookmarked, comment: comment)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    static let shared = MovieRepository()
}
