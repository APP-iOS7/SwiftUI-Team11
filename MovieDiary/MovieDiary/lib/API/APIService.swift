//
//  APIService.swift
//  MovieDiary
//
//  Created by Saebyeok Jang on 3/10/25.
//

import Foundation
import Combine

// API 호출 중 발생할 수 있는 에러 타입
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

// 영화 API 서비스 프로토콜
protocol MovieAPIServiceProtocol {
    func getMovies(endpoint: MovieEndpoint, page: Int) -> AnyPublisher<MovieResponse, APIError>
    func searchMovies(query: String, page: Int) -> AnyPublisher<MovieResponse, APIError>
    func getMovieDetail(id: Int) -> AnyPublisher<MovieDetail, APIError>
    func updateMovie(id: Int, rate: Double?, isBookmarked: Bool?, comment: String?) -> AnyPublisher<Void, APIError>
}

// 영화 API 엔드포인트
enum MovieEndpoint {
    case popular
    case nowPlaying
    case topRated
    case upcoming
    
    var path: String {
        switch self {
        case .popular:
            return "select?model=item_movie&page=1"
        case .nowPlaying:
            return "select?model=item_movie&page=1"
        case .topRated:
            return "select?model=item_movie&page=1"
        case .upcoming:
            return "select?model=item_movie&page=1"
        }
    }
}

// API 서비스 구현
class MovieDiaryAPIService: MovieAPIServiceProtocol {
    private let baseURL = "https://5d8a-49-246-51-78.ngrok-free.app"
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    
    init(urlSession: URLSession = .shared, jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
    }
    
    // 영화 목록 가져오기
    func getMovies(endpoint: MovieEndpoint, page: Int = 1) -> AnyPublisher<MovieResponse, APIError> {
        let urlString: String
        
        switch endpoint {
        case .popular:
            urlString = "\(baseURL)/select?model=item_movie&page=\(page)"
        case .nowPlaying:
            urlString = "\(baseURL)/select?model=item_movie&page=\(page)"
        case .topRated:
            urlString = "\(baseURL)/select?model=item_movie&page=\(page)"
        case .upcoming:
            urlString = "\(baseURL)/select?model=item_movie&page=\(page)"
        }
        
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        print("🟢 API 요청: \(url.absoluteString)")
        
        return urlSession.dataTaskPublisher(for: url)
            .mapError { APIError.networkError($0) }
            .flatMap { data, response -> AnyPublisher<MovieResponse, APIError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: APIError.invalidResponse).eraseToAnyPublisher()
                }
                
                print("🟢 응답 상태 코드: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("🔴 서버 오류: \(httpResponse.statusCode)")
                    return Fail(error: APIError.serverError(httpResponse.statusCode)).eraseToAnyPublisher()
                }
                
                return Just(data)
                    .decode(type: MovieResponse.self, decoder: self.jsonDecoder)
                    .mapError { error in
                        print("🔴 디코딩 오류: \(error)")
                        return APIError.decodingError
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // 영화 검색하기
    func searchMovies(query: String, page: Int = 1) -> AnyPublisher<MovieResponse, APIError> {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        let urlString = "\(baseURL)/search?query=\(encodedQuery)&page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        print("🟢 API 검색 요청: \(url.absoluteString)")
        
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
    
    // 영화 상세 정보 가져오기
    func getMovieDetail(id: Int) -> AnyPublisher<MovieDetail, APIError> {
        let urlString = "\(baseURL)/searchId?movie_id=\(id)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        print("🟢 영화 상세 요청: \(url.absoluteString)")
        
        return urlSession.dataTaskPublisher(for: url)
            .mapError { APIError.networkError($0) }
            .flatMap { data, response -> AnyPublisher<MovieDetail, APIError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: APIError.invalidResponse).eraseToAnyPublisher()
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: APIError.serverError(httpResponse.statusCode)).eraseToAnyPublisher()
                }
                
                // searchId 응답은 MovieDetail과 다른 형태로 오기 때문에 추가 처리 필요
                return Just(data)
                    .decode(type: SearchIdResponse.self, decoder: self.jsonDecoder)
                    .tryMap { response -> MovieDetail in
                        if let movie = response.movieResults.first {
                            return MovieDetail(
                                id: movie.id,
                                title: movie.title,
                                overview: movie.overview,
                                posterPath: movie.posterPath,
                                backdropPath: movie.backdropPath,
                                voteAverage: movie.voteAverage,
                                releaseDate: movie.releaseDate,
                                runtime: nil,
                                genres: movie.genreIds.map { Genre(id: 0, name: $0) },
                                productionCountries: nil
                            )
                        } else {
                            throw APIError.decodingError
                        }
                    }
                    .mapError { error -> APIError in
                        if let apiError = error as? APIError {
                            return apiError
                        }
                        return APIError.decodingError
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // 영화 정보 업데이트 (평점, 북마크, 코멘트)
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
        
        print("🟢 영화 업데이트 요청: \(url.absoluteString)")
        
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
}

// 응답 모델들

// 영화 기본 모델
struct Movie: Identifiable, Decodable {
    let id: Int
    let title: String
    let posterPath: String
    let voteAverage: Double
    let releaseDate: String?
    let backdropPath: String?
    let overview: String?
    let genreIds: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case backdropPath = "backdrop_path"
        case overview
        case genreIds = "genre_ids"
    }
    
    var posterURL: URL? {
        guard let posterPath = posterPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    var backdropURL: URL? {
        guard let backdropPath = backdropPath?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: "https://image.tmdb.org/t/p/original\(backdropPath)")
    }
    
    var isUpcoming: Bool {
        guard let releaseDateString = releaseDate, !releaseDateString.isEmpty else {
            return false
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let releaseDate = formatter.date(from: releaseDateString) else {
            return false
        }
        
        return releaseDate > Date()
    }
    
    var daysUntilRelease: String? {
        guard let releaseDateString = releaseDate, !releaseDateString.isEmpty else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let releaseDate = formatter.date(from: releaseDateString) else {
            return nil
        }
        
        // 오늘 날짜와의 차이 계산
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let releaseDay = calendar.startOfDay(for: releaseDate)
        
        if let days = calendar.dateComponents([.day], from: today, to: releaseDay).day, days >= 0 {
            return "D-\(days)"
        }
        
        return nil
    }
}

// 영화 상세 정보 모델
struct MovieDetail: Decodable, Identifiable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let releaseDate: String?
    let runtime: Int?
    let genres: [Genre]?
    let productionCountries: [ProductionCountry]?
    
    var posterURL: URL? {
        guard let posterPath = posterPath?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    var backdropURL: URL? {
        guard let backdropPath = backdropPath?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: "https://image.tmdb.org/t/p/original\(backdropPath)")
    }
}

// 장르 모델
struct Genre: Decodable, Identifiable {
    let id: Int
    let name: String
}

// 제작 국가 모델
struct ProductionCountry: Decodable {
    let iso31661: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case iso31661 = "iso_3166_1"
        case name
    }
}

// API 응답 모델
struct MovieResponse: Decodable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// SearchId API 응답 모델
struct SearchIdResponse: Decodable {
    let movieResults: [Movie]
    
    enum CodingKeys: String, CodingKey {
        case movieResults = "movie_results"
    }
}

// 싱글톤 인스턴스
extension MovieDiaryAPIService {
    static let shared = MovieDiaryAPIService()
}
