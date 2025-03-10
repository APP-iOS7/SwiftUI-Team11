//
//  HomeViewModel.swift
//  MovieDiary
//
//  Created by Saebyeok Jang on 3/10/25.
//

import SwiftUI
import Combine

enum MovieGenre: String, CaseIterable {
    case action = "액션"
    case comedy = "코미디"
    case crime = "범죄"
    case drama = "드라마"
    case horror = "공포"
    case scienceFiction = "SF"
    
    var genreId: String {
        switch self {
        case .action: return "%5B%22%EC%95%A1%EC%85%98%22%5D"
        case .comedy: return "코미디"
        case .crime: return aa()
        case .drama: return "['액션']"
        case .horror: return "27"
        case .scienceFiction: return "878"
        }
    }
    func aa() -> String {
        let genres = ["액션"]
        if let jsonData = try? JSONEncoder().encode(genres),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
            return jsonString
        } else {
            return ""
        }
    }
}

struct MovieCategory: Identifiable {
    let id = UUID()
    let title: String
    let genre: MovieGenre
    var movies: [Movie] = []
}

class HomeViewModel: ObservableObject {
    @Published var categories: [MovieCategory] = []
    
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    
    private let repository: MovieRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: MovieRepositoryProtocol = MovieRepository.shared) {
        self.repository = repository
        initCategories()
    }
    
    private func initCategories() {
        categories = [
            MovieCategory(title: "액션", genre: MovieGenre.action),
            MovieCategory(title: "코미디", genre: MovieGenre.comedy),
            MovieCategory(title: "범죄", genre: MovieGenre.crime),
            MovieCategory(title: "드라마", genre: MovieGenre.drama),
            MovieCategory(title: "공포", genre: MovieGenre.horror),
            MovieCategory(title: "SF", genre: MovieGenre.scienceFiction)
        ]
    }
    
    func loadData() {
        isRefreshing = true
        errorMessage = nil
        
        let publishers = categories.map { category in
            return fetchCategoryMovies(for: category.genre)
                .catch { error -> AnyPublisher<[Movie], Never> in
                    print("Error fetching movies for genre \(category.genre): \(error)")
                    return Just([]).eraseToAnyPublisher()
                }
        }
        
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    let detailedError = "데이터를 불러오는 중 오류가 발생했습니다: \(error.localizedDescription)"
                    print(detailedError)
                    self?.errorMessage = detailedError
                }
                self?.isRefreshing = false
            } receiveValue: { [weak self] moviesArray in
                guard let self = self else { return }
                for (index, movies) in moviesArray.enumerated() {
                    print("Loaded \(movies.count) movies for genre \(self.categories[index].genre)")
                    self.categories[index].movies = movies
                }
                
                // 모든 카테고리의 영화 수 출력
                let totalMovies = self.categories.reduce(0) { $0 + $1.movies.count }
                print("Total movies loaded across all categories: \(totalMovies)")
                
                if totalMovies == 0 {
                    self.errorMessage = "영화 데이터를 불러오지 못했습니다. 네트워크 연결을 확인해주세요."
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchCategoryMovies(for genre: MovieGenre) -> AnyPublisher<[Movie], Error> {
        return repository.getMoviesByGenre(genreId: genre.genreId)
            .eraseToAnyPublisher()
    }
    
    func refresh() async {
        await withCheckedContinuation { continuation in
            for i in 0..<categories.count {
                categories[i].movies = []
            }
            loadData()
            $isRefreshing
                .dropFirst()
                .filter { !$0 }
                .first()
                .sink { _ in
                    continuation.resume()
                }
                .store(in: &cancellables)
        }
    }
    
    func searchMovies(query: String) -> AnyPublisher<[Movie], Never> {
        guard !query.isEmpty else {
            return Just([]).eraseToAnyPublisher()
        }
        
        return repository.searchMovies(query: query, page: 1)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func updateMovie(id: Int, rate: Double? = nil, isBookmarked: Bool? = nil, comment: String? = nil) -> AnyPublisher<Bool, Never> {
        repository.updateMovie(id: id, rate: rate, isBookmarked: isBookmarked, comment: comment)
            .map { _ in true }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
