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
//                                                MoviePosterView(movie: movie)
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
                VStack {
                    if viewModel.isRefreshing {
                        HStack {
                            Spacer()
                            ProgressView("새로고침 중")
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemBackground).opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 3)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        HStack {
                            Spacer()
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                                .background(Color(.systemBackground).opacity(0.9))
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

struct MoviePosterView: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: movie.posterURL) { phase in
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
                
                // D-Day 뱃지
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
