//
//  HomeView.swift
//  MovieDiary
//
//  Created by Saebyeok Jang on 3/7/25.
//

import SwiftUI
import Combine

//MARK: - 데이터 모델

struct Movie: Identifiable, Decodable {
    let id: Int
    let title: String
    let posterPath: String
    let voteAverage: Double
    let releaseDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
    }
    
    var posterURL: URL? {
        URL(string: "https://image.tmdb.org/t/p/w200\(posterPath)")
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

// 영화 카테고리 모델
struct Category: Identifiable {
    let id = UUID()
    let title: String
    let endpoint: String
    var movies: [Movie] = []
}

//MARK: - API

class MovieService: ObservableObject {
    private let baseURL = "https://api.themoviedb.org/3"
    private let apiKey = "41fc8d2ac9a61bac1984c410839219c6"
    
    // 영화 데이터를 가져오는 함수
    func fetchMovies(from endpoint: String) -> AnyPublisher<[Movie], Error> {
        // (기본 URL + 엔드포인트 + API키 + 언어 설정)
        guard let url = URL(string: "\(baseURL)/\(endpoint)?api_key=\(apiKey)&language=ko-KR") else {
            // URL is NOT유효? 에러 반환
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        // URL 세션을 사용해 결과 처리
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: MovieResponse.self, decoder: JSONDecoder())
            .map(\.results)
            .eraseToAnyPublisher()
    }
    
    struct MovieResponse: Decodable {
        let results: [Movie]
    }
}

//MARK: - 홈 뷰 모델

class HomeViewModel: ObservableObject {
    @Published var categories: [Category] = [
        Category(title: "인기 영화", endpoint: "movie/popular"),
        Category(title: "최신 개봉작", endpoint: "movie/now_playing"),
        Category(title: "높은 평점", endpoint: "movie/top_rated"),
        Category(title: "개봉 예정", endpoint: "movie/upcoming")
    ]
    
    // 새로고침(true면 로딩 중, false면 완료)
    @Published var isRefreshing = false
    
    private let movieService = MovieService()
    private var cancellables = Set<AnyCancellable>()
    
    // 영화 데이터 로드
    func loadData() {
        isRefreshing = true
        
        let publishers = categories.indices.map { index in
            return fetchCategoryMovies(at: index)
        }
        
        // 완료 시 새로고침 상태를 false로 설정
        Publishers.MergeMany(publishers) // publisher 병합
            .collect()
            .sink { [weak self] _ in
                // 완료되면 새로고침 상태 업데이트
                self?.isRefreshing = false
            }
            .store(in: &cancellables) // 메모리 누수 방지
    }
    
    // 특정 카테고리의 영화 데이터 로드
    private func fetchCategoryMovies(at index: Int) -> AnyPublisher<Void, Never> {
        return movieService.fetchMovies(from: categories[index].endpoint)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] movies in
                // 가져온 영화 데이터를 카테고리에 할당
                self?.categories[index].movies = movies
            })
            .map { _ in () }
            .catch { error -> Just<Void> in
                print("Error fetching \(self.categories[index].title): \(error.localizedDescription)")
                return Just(())
            }
            .eraseToAnyPublisher()
    }
    
    // 당겨서 새로고침 기능에서 호출되는 비동기 함수
    func refresh() async {
        // 비동기 코드를 동기식으로 기다리기 위한 방법
        await withCheckedContinuation { continuation in
            // 영화 목록 초기화
            for i in 0..<categories.count {
                categories[i].movies = []
            }
            loadData()
            $isRefreshing
                .dropFirst() // 첫 번째 값(true)는 무시 (loadData() 호출 직후의 값)
                .filter { !$0 } // isRefreshing이 false일 때만 통과
                .first() // 첫 번째 이벤트만 처리
                .sink { _ in
                    continuation.resume()
                }
                .store(in: &cancellables) // 메모리 누수 방지
        }
    }
}

//MARK: - 홈뷰

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.categories) { category in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(category.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.leading)
                            
                            // 영화 목록이 비어있으면 로딩 표시
                            if category.movies.isEmpty {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .padding()
                                    Spacer()
                                }
                            } else {
                                // 가로 스크롤
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(category.movies) { movie in
                                            // 영화 클릭 시 상세 페이지로
                                            NavigationLink(destination: posterItemDetailView(movieId: movie.id)) {
                                                MoviePosterView(movie: movie)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("MovieDiary")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refresh()
            }
            .overlay(
                Group {
                    if viewModel.isRefreshing {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ProgressView("새로고침 중")
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemBackground).opacity(0.8))
                            .cornerRadius(10)
                            .shadow(radius: 3)
                            Spacer()
                        }
                    }
                }
            )
            .onAppear {
                viewModel.loadData()
            }
        }
    }
}

//MARK: - 컴포넌트

struct MoviePosterView: View {
    let movie: Movie // 표시할 영화 데이터
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            AsyncImage(url: movie.posterURL) { phase in
                switch phase {
                case .empty: // 로딩 중
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(2/3, contentMode: .fit)
                            .frame(width: 120)
                            .cornerRadius(8)
                        
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(2/3, contentMode: .fit)
                        .frame(width: 120)
                        .cornerRadius(8)
                case .failure:
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(2/3, contentMode: .fit)
                            .frame(width: 120)
                            .cornerRadius(8)
                        
                        // 영화 제목의 첫 글자를 표시
                        Text(movie.title.prefix(1))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                @unknown default:
                    EmptyView()
                }
            }
            
            if let daysUntilRelease = movie.daysUntilRelease {
                Text(daysUntilRelease)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.red)
                    .cornerRadius(4)
                    .padding(6)
            }
            
            // 제목
            Text(movie.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.black)
                .lineLimit(1)
            
            // 평점 or 출시 예정
            if movie.voteAverage > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption2)
                    
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }
            } else {
                Text("출시 예정")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 120)
    }
}

/// **(테스트용)** <영화 상세 정보 페이지> **(테스트용)**
struct MovieDetailView: View {
    let movieId: Int
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
        Text("(요한님의 디테일 뷰로 이동)")
            .navigationTitle(title)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
