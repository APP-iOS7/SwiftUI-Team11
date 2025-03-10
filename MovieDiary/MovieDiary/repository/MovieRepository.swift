//
//  MovieRepository.swift
//  MovieDiary
//
//  Created by Saebyeok Jang on 3/10/25.
//

import Foundation
import Combine

protocol MovieRepositoryProtocol {
    func getMoviesByGenre(genreId: String) -> AnyPublisher<[ItemMovie], Error>
    func searchMovies(query: String, page: Int) -> AnyPublisher<[ItemMovie], Error>
    func updateMovie(id: Int, rate: Double?, isBookmarked: Bool?, comment: String?) -> AnyPublisher<Void, Error>
}

class MovieRepository: MovieRepositoryProtocol {
    private let apiService: MovieAPIServiceProtocol
    
    init(apiService: MovieAPIServiceProtocol = MovieDiaryAPIService.shared) {
        self.apiService = apiService
    }
    
    func getMoviesByGenre(genreId: String) -> AnyPublisher<[ItemMovie], Error> {
        return apiService.getMoviesByGenre(genreId: genreId, page: 1)
            .map { response in
                return response.results
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func searchMovies(query: String, page: Int = 1) -> AnyPublisher<[ItemMovie], Error> {
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
