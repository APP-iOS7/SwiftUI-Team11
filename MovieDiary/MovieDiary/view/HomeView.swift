//
//  HomeView.swift
//  MovieDiary
//
//  Created by Saebyeok Jang on 3/7/25.
//

import SwiftUI
import Combine

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var isRefreshing = false
    @State private var rotationDegree: Double = 0
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle(isRefreshing ? "" : "MovieDiary")
                .navigationBarTitleDisplayMode(.large)
                .refreshable {
                    isRefreshing = true
                    await viewModel.refresh()
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    isRefreshing = false
                }
                .onAppear {
                    if viewModel.categories.flatMap({ $0.movies }).isEmpty {
                        viewModel.loadData()
                    }
                }
        }
    }
    
    // 메인 콘텐츠를 별도의 계산 속성으로 분리
    private var content: some View {
        ZStack {
            if shouldShowMainContent {
                mainContentView
            } else if viewModel.isDataLoading {
                loadingView
            }
            else {
                errorView
            }
        }
    }
    
    // 메인 콘텐츠 표시 여부 조건
    private var shouldShowMainContent: Bool {
        !viewModel.isDataLoading && !viewModel.categories.flatMap({ $0.movies }).isEmpty
    }
    
    // 메인 콘텐츠 뷰
    private var mainContentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(viewModel.categories) { category in
                    if !category.movies.isEmpty {
                        categoryView(for: category)
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    // 각 카테고리별 뷰
    private func categoryView(for category: MovieCategory) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(category.title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.leading)
            
            // 가로 스크롤
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(category.movies) { movie in
                        movieLink(for: movie)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // 영화 링크 뷰
    private func movieLink(for movie: ItemMovie) -> some View {
        NavigationLink(destination: posterItemDetailView(movieId: movie.id)) {
            MoviePosterView(movie: movie)
        }
    }
    
    // 로딩 뷰
    private var loadingView: some View {
        VStack(spacing: 20) {
            Image(systemName: "film")
                .font(.system(size: 50))
                .foregroundColor(.black)
                .rotationEffect(.degrees(rotationDegree))
            
            Text("영화 데이터를 불러오는 중...")
                .font(.headline)
                .foregroundColor(.gray)
        }
    }
    
    // 에러 뷰
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("영화 데이터를 불러올 수 없습니다")
                .font(.headline)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                viewModel.loadData()
            }) {
                Text("다시 시도")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.top)
        }
    }
}

struct MoviePosterView: View {
    let movie: ItemMovie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath)")) { phase in
                    switch phase {
                    case .empty:
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
                
                // D-Day 뱃지 (릴리즈 날짜 계산 필요)
                let daysUntil = calculateDaysUntilRelease(movie.releaseDate)
                if let daysText = daysUntil {
                    Text(daysText)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.red)
                        .cornerRadius(4)
                        .padding(6)
                }
            }
            
            // 제목
            Text(movie.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.black)
                .lineLimit(1)
            
            // 평점
            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption2)
                
                Text(String(format: "%.1f", movie.rate))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
            }
        }
        .frame(width: 120)
    }
    
    // 개봉일까지 남은 날짜 계산
    func calculateDaysUntilRelease(_ releaseDate: Date) -> String? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: releaseDate)
        
        guard let days = components.day else { return nil }
        
        if days < 0 {
            return nil
        } else if days == 0 {
            return "오늘 개봉"
        } else {
            return "D-\(days)"
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
