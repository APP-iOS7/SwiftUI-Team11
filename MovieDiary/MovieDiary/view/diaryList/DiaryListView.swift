//
//  DiaryListView.swift
//  MovieDiary
//
//  Created by 심연아 on 3/7/25.
//

import SwiftUI

struct DiaryListView: View {
    @State private var selectedFilter: DiaryListFilter = .wish
    @State private var onSheet: Bool = false
    @State private var movieInfo: SearchResults?
    
//    var item: ItemMovie
    @Namespace var animation
    
    private var filterBarWidth: CGFloat {
        let count = CGFloat(DiaryListFilter.allCases.count)
        return UIScreen.main.bounds.width / count - 16
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                
                // 사용자 정보 헤더
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("심연아")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("yeon_ah")
                                .font(.subheadline)
                        }
                    }
                    Spacer()
                    
                    CircularProfileImageView()
                }
                .onAppear() {
                    
                }

                // 필터 선택 바
                HStack {
                    ForEach(DiaryListFilter.allCases) { filter in
                        VStack {
                            Text(filter.title)
                                .font(.subheadline)
                                .fontWeight(selectedFilter == filter ? .semibold : .regular)
                            
                            Rectangle()
                                .foregroundColor(selectedFilter == filter ? .black : .clear)
                                .frame(width: filterBarWidth, height: 1)
                                .matchedGeometryEffect(id: "item", in: animation)
                        }
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedFilter = filter
                            }
                        }
                    }
                }
                
                // 영화 리스트
                LazyVStack {
                    if let movieInfo = movieInfo {
                        ForEach(movieInfo.movieDetails, id: \.id) { movie in
                            MovieCell(
                                item: movie,
                                posterPath: movie.posterPath
                            )
                            Divider()
                        }
                    } else {
                        ProgressView("영화 정보를 불러오는 중...")
                    }
                }
                .padding(.vertical, 8)
            }
            .padding(.horizontal)
        }
        .onAppear {
            fetchMovieInfo()
        }
    }
    
    private func fetchMovieInfo() {
        Task {
            guard let fetchedMovieInfo = await serchIDRequest(id: item.id) else { return }
            movieInfo = fetchedMovieInfo
        }
    }
}

// 프로필 이미지 뷰
struct CircularProfileImageView: View {
    var body: some View {
        Image("testImage")
            .resizable()
            .scaledToFill()
            .frame(width: 50, height: 50)
            .clipShape(Circle())
    }
}


//#Preview {
//    DiaryListView()
//}
