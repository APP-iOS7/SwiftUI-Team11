//
//  APIService.swift
//  MovieDiary
//
//  Created by Saebyeok Jang on 3/10/25.
//

import Foundation
import Combine

struct Genre: Codable {
    let id: Int
    let name: String
}

struct MovieDetailResponse: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let releaseDate: String?
    let runtime: Int?
    let genres: [Genre]
    let productionCountries: [Country]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case runtime, genres
        case productionCountries = "production_countries"
    }
}

struct Country: Codable {
    let name: String
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(Int)
    case networkError(Error)
    
    var message: String {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .invalidResponse:
            return "서버로부터 유효하지 않은 응답이 왔습니다."
        case .decodingError:
            return "데이터 디코딩 중 오류가 발생했습니다."
        case .serverError(let code):
            return "서버 오류: \(code)"
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        }
    }
}

protocol MovieAPIServiceProtocol {
    func getMovies(endpoint: MovieEndpoint, page: Int) -> AnyPublisher<MovieResponse, APIError>
    func searchMovies(query: String, page: Int) -> AnyPublisher<MovieResponse, APIError>
    func getMovieDetail(id: Int) -> AnyPublisher<MovieDetailResponse, APIError>
    func updateMovie(id: Int, rate: Double?, isBookmarked: Bool?, comment: String?) -> AnyPublisher<Void, APIError>
    func getMoviesByGenre(genreId: Int, page: Int) -> AnyPublisher<MovieResponse, APIError>
}

enum MovieEndpoint {
    case popular
    case nowPlaying
    case topRated
    case upcoming
    
    var path: String {
        switch self {
        case .popular:
            return "select?model=item_movie&amp;page=1"
        case .nowPlaying:
            return "select?model=item_movie&amp;page=1"
        case .topRated:
            return "select?model=item_movie&amp;page=1"
        case .upcoming:
            return "select?model=item_movie&amp;page=1"
        }
    }
}

class MovieDiaryAPIService: MovieAPIServiceProtocol {
    private let baseURL: String
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    
    init(baseURL: String = "https://a692-49-246-51-78.ngrok-free.app", urlSession: URLSession = .shared, jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.baseURL = baseURL
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        configuration.waitsForConnectivity = true
        
        self.urlSession = URLSession(configuration: configuration)
        self.jsonDecoder = jsonDecoder
    }
    
    func getMovies(endpoint: MovieEndpoint, page: Int = 1) -> AnyPublisher<MovieResponse, APIError> {
        let urlString = "\(baseURL)/\(endpoint.path)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: url)
            .mapError { APIError.networkError($0) }
            .flatMap { data, response -> AnyPublisher<MovieResponse, APIError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: APIError.invalidResponse).eraseToAnyPublisher()
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: APIError.serverError(httpResponse.statusCode)).eraseToAnyPublisher()
                }
                
                return Just(data)
                    .decode(type: MovieResponse.self, decoder: self.jsonDecoder)
                    .mapError { _ in APIError.decodingError }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func searchMovies(query: String, page: Int = 1) -> AnyPublisher<MovieResponse, APIError> {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        let urlString = "\(baseURL)/search?query=\(encodedQuery)&amp;page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: url)
            .mapError { APIError.networkError($0) }
            .flatMap { data, response -> AnyPublisher<MovieResponse, APIError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: APIError.invalidResponse).eraseToAnyPublisher()
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: APIError.serverError(httpResponse.statusCode)).eraseToAnyPublisher()
                }
                
                return Just(data)
                    .decode(type: MovieResponse.self, decoder: self.jsonDecoder)
                    .mapError { _ in APIError.decodingError }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getMovieDetail(id: Int) -> AnyPublisher<MovieDetailResponse, APIError> {
        let urlString = "\(baseURL)/searchId?movie_id=\(id)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: url)
            .mapError { APIError.networkError($0) }
            .flatMap { data, response -> AnyPublisher<MovieDetailResponse, APIError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: APIError.invalidResponse).eraseToAnyPublisher()
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: APIError.serverError(httpResponse.statusCode)).eraseToAnyPublisher()
                }
                
                return Just(data)
                    .decode(type: MovieDetailResponse.self, decoder: self.jsonDecoder)
                    .mapError { _ in APIError.decodingError }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func updateMovie(id: Int, rate: Double?, isBookmarked: Bool?, comment: String?) -> AnyPublisher<Void, APIError> {
        var urlComponents = URLComponents(string: "\(baseURL)/update")
        var queryItems = [URLQueryItem(name: "model", value: "item_movie"), URLQueryItem(name: "id", value: "\(id)")]
        
        if let rate = rate {
            queryItems.append(URLQueryItem(name: "rate", value: "\(rate)"))
        }
        
        if let isBookmarked = isBookmarked {
            queryItems.append(URLQueryItem(name: "is_bookmarked", value: "\(isBookmarked)"))
        }
        
        if let comment = comment {
            queryItems.append(URLQueryItem(name: "comment", value: comment))
        }
        
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: url)
            .mapError { APIError.networkError($0) }
            .flatMap { data, response -> AnyPublisher<Void, APIError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: APIError.invalidResponse).eraseToAnyPublisher()
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: APIError.serverError(httpResponse.statusCode)).eraseToAnyPublisher()
                }
                
                return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getMoviesByGenre(genreId: Int, page: Int = 1) -> AnyPublisher<MovieResponse, APIError> {
        let urlString = "\(baseURL)/select?model=item_movie&amp;page=\(page)&amp;genre_ids=[\"\(genreId)\"]"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: url)
            .mapError { APIError.networkError($0) }
            .flatMap { data, response -> AnyPublisher<MovieResponse, APIError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: APIError.invalidResponse).eraseToAnyPublisher()
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: APIError.serverError(httpResponse.statusCode)).eraseToAnyPublisher()
                }
                
                return Just(data)
                    .decode(type: MovieResponse.self, decoder: self.jsonDecoder)
                    .mapError { _ in APIError.decodingError }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    static let shared = MovieDiaryAPIService()
}
