//
//  MovieRepository.swift
//  MovieDiary
//
//  Created by Saebyeok Jang on 3/10/25.
//

import Foundation
import Combine

// 영화 데이터 저장소 프로토콜
protocol MovieRepositoryProtocol {
    func getPopularMovies() -> AnyPublisher<[Movie], Error>
    func getNowPlayingMovies() -> AnyPublisher<[Movie], Error>
    func getTopRatedMovies() -> AnyPublisher<[Movie], Error>
    func getUpcomingMovies() -> AnyPublisher<[Movie], Error>
    func getMovieDetail(id: Int) -> AnyPublisher<MovieDetail, Error>
    func searchMovies(query: String, page: Int) -> AnyPublisher<[Movie], Error>
    func updateMovie(id: Int, rate: Double?, isBookmarked: Bool?, comment: String?) -> AnyPublisher<Void, Error>
}

// 영화 데이터 저장소 구현
class MovieRepository: MovieRepositoryProtocol {
    private let apiService: MovieAPIServiceProtocol
    
    init(apiService: MovieAPIServiceProtocol = MovieDiaryAPIService.shared) {
        self.apiService = apiService
    }
    
    func getPopularMovies() -> AnyPublisher<[Movie], Error> {
        return apiService.getMovies(endpoint: .popular, page: 1)
            .map { (response: MovieResponse) -> [Movie] in
                return response.results
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func getNowPlayingMovies() -> AnyPublisher<[Movie], Error> {
        return apiService.getMovies(endpoint: .nowPlaying, page: 1)
            .map { (response: MovieResponse) -> [Movie] in
                return response.results
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func getTopRatedMovies() -> AnyPublisher<[Movie], Error> {
        return apiService.getMovies(endpoint: .topRated, page: 1)
            .map { (response: MovieResponse) -> [Movie] in
                return response.results
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func getUpcomingMovies() -> AnyPublisher<[Movie], Error> {
        return apiService.getMovies(endpoint: .upcoming, page: 1)
            .map { (response: MovieResponse) -> [Movie] in
                return response.results
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func getMovieDetail(id: Int) -> AnyPublisher<MovieDetail, Error> {
        return apiService.getMovieDetail(id: id)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func searchMovies(query: String, page: Int = 1) -> AnyPublisher<[Movie], Error> {
        return apiService.searchMovies(query: query, page: page)
            .map { (response: MovieResponse) -> [Movie] in
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
}

// 싱글톤 인스턴스
extension MovieRepository {
    static let shared = MovieRepository()
}
