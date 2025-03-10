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
        return self.rawValue
    }
}

struct MovieCategory: Identifiable {
    let id = UUID()
    let title: String
    let genre: MovieGenre
    var movies: [ItemMovie] = []
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
    
    func loadData(page: Int = 1) {
        isRefreshing = true
        errorMessage = nil
        
        let publishers = categories.map { category in
            return fetchCategoryMovies(for: category.genre)
                .catch { error -> AnyPublisher<[ItemMovie], Never> in
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
                
                let totalMovies = self.categories.reduce(0) { $0 + $1.movies.count }
                print("Total movies loaded across all categories: \(totalMovies)")
                
                if totalMovies == 0 {
                    self.errorMessage = "장르별 영화 데이터를 불러오지 못했습니다. 서버 상태를 확인해주세요."
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchCategoryMovies(for genre: MovieGenre) -> AnyPublisher<[ItemMovie], Error> {
        // 장르 ID JSON 문자열로 생성 ["액션"] 같은 형식
        let encodedGenreIds = "[\"\(genre.genreId)\"]"
        print("요청 중인 장르: \(genre.rawValue), 인코딩된 ID: \(encodedGenreIds)")
        
        // API 문서에 따라 URL 인코딩 필요
        guard let urlEncodedGenreIds = encodedGenreIds.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("장르 ID 인코딩 실패")
            return Fail(error: NSError(domain: "EncodingError", code: -1, userInfo: nil)).eraseToAnyPublisher()
        }
        
        return repository.getMoviesByGenre(genreId: urlEncodedGenreIds)
            .handleEvents(
                receiveOutput: { movies in
                    print("장르 \(genre.rawValue)에 대해 \(movies.count)개의 영화 로드됨")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("장르 \(genre.rawValue) 데이터 로드 실패: \(error)")
                    }
                }
            )
            .mapError { $0 as Error }
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
    
    func searchMovies(query: String) -> AnyPublisher<[ItemMovie], Never> {
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
