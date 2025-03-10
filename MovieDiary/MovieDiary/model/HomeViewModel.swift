//
//  HomeViewModel.swift
//  MovieDiary
//
//  Created by Saebyeok Jang on 3/10/25.
//

import SwiftUI
import Combine

// 영화 카테고리 모델
struct MovieCategory: Identifiable {
    let id = UUID()
    let title: String
    let type: CategoryType
    var movies: [Movie] = []
    
    enum CategoryType {
        case popular
        case nowPlaying
        case topRated
        case upcoming
    }
}

class HomeViewModel: ObservableObject {
    @Published var categories: [MovieCategory] = [
        MovieCategory(title: "인기 영화", type: .popular),
        MovieCategory(title: "최신 개봉작", type: .nowPlaying),
        MovieCategory(title: "높은 평점", type: .topRated),
        MovieCategory(title: "개봉 예정", type: .upcoming)
    ]
    
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    
    private let repository: MovieRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: MovieRepositoryProtocol = MovieRepository.shared) {
        self.repository = repository
    }
    
    // 영화 데이터 로드
    func loadData() {
        isRefreshing = true
        errorMessage = nil
        
        let publishers = categories.indices.map { index in
            return fetchCategoryMovies(at: index)
        }
        
        Publishers.MergeMany(publishers)
            .collect()
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = "데이터를 불러오는 중 오류가 발생했습니다: \(error.localizedDescription)"
                    print("🔴 데이터 로드 오류: \(error.localizedDescription)")
                }
                self?.isRefreshing = false
            } receiveValue: { _ in
                print("🟢 모든 카테고리 데이터 로드 완료")
            }
            .store(in: &cancellables)
        
        #if DEBUG
        // 테스트용 더미 데이터 추가 (실제 API 연결이 안 될 경우를 대비)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            
            var shouldAddDummyData = false
            for category in self.categories {
                if category.movies.isEmpty {
                    shouldAddDummyData = true
                    break
                }
            }
            
            if shouldAddDummyData {
                print("테스트용 더미 데이터")
                for i in 0..<4 {
                    let dummyMovies = (1...5).map { j -> Movie in
                        return Movie(
                            id: i * 100 + j,
                            title: "테스트 영화 \(i)-\(j)",
                            posterPath: "/path/to/poster.jpg",
                            voteAverage: Double.random(in: 5...9),
                            releaseDate: "2025-0\(i+1)-\(j*5)",
                            backdropPath: "/path/to/backdrop.jpg",
                            overview: "테스트 영화입니다.",
                            genreIds: ["액션", "드라마"]
                        )
                    }
                    self.categories[i].movies = dummyMovies
                }
            }
        }
        #endif
    }
    
    // 특정 카테고리의 영화 데이터 로드
    private func fetchCategoryMovies(at index: Int) -> AnyPublisher<Void, Error> {
        let categoryType = categories[index].type
        
        let publisher: AnyPublisher<[Movie], Error>
        
        switch categoryType {
        case .popular:
            publisher = repository.getPopularMovies()
        case .nowPlaying:
            publisher = repository.getNowPlayingMovies()
        case .topRated:
            publisher = repository.getTopRatedMovies()
        case .upcoming:
            publisher = repository.getUpcomingMovies()
        }
        
        return publisher
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] movies in
                self?.categories[index].movies = movies
                print("🟢 로드 완료: \(self?.categories[index].title ?? "") - \(movies.count)개 영화")
            })
            .map { _ in () }
            .catch { error -> AnyPublisher<Void, Error> in
                print("🔴 Error fetching \(self.categories[index].title): \(error.localizedDescription)")
                return Fail(error: error)
                    .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // 당겨서 새로고침 기능에서 호출되는 비동기 함수
    func refresh() async {
        await withCheckedContinuation { continuation in
            // 영화 목록 초기화
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
    
    // 영화 검색 기능
    func searchMovies(query: String) -> AnyPublisher<[Movie], Never> {
        guard !query.isEmpty else {
            return Just([]).eraseToAnyPublisher()
        }
        
        return repository.searchMovies(query: query, page: 1)
            .catch { error -> Just<[Movie]> in
                print("🔴 검색 오류: \(error.localizedDescription)")
                return Just([])
            }
            .eraseToAnyPublisher()
    }
    
    // 영화 업데이트 기능 (평점, 북마크, 코멘트)
    func updateMovie(id: Int, rate: Double? = nil, isBookmarked: Bool? = nil, comment: String? = nil) -> AnyPublisher<Bool, Never> {
        repository.updateMovie(id: id, rate: rate, isBookmarked: isBookmarked, comment: comment)
            .map { _ in true }
            .catch { error -> Just<Bool> in
                print("🔴 영화 업데이트 오류: \(error.localizedDescription)")
                return Just(false)
            }
            .eraseToAnyPublisher()
    }
}
