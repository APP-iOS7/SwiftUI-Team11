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
    @State private var movieInfo: [ForMovieCell] = []
    
    @Namespace var animation
    
    private var filterBarWidth: CGFloat {
        let count = CGFloat(DiaryListFilter.allCases.count)
        return UIScreen.main.bounds.width / count - 16
    }
    
    var body: some View {
        NavigationStack {
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
                                    .matchedGeometryEffect(id: filter.title, in: animation)
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
                        if movieInfo.isEmpty {
                            ProgressView("영화 정보를 불러오는 중...")
                        } else {
                            ForEach(movieInfo, id: \.id) { movie in
                                NavigationLink(destination: posterItemDetailView(movieId: movie.id)) {
                                    MovieCell(movieInfo: movie)
                                }
                                Divider()
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal)
            }
            .onChange(of: selectedFilter) {
                print(selectedFilter)
                if selectedFilter == .wish {
                    fetchMovieInfo(kind: "bookmark", page: 1)
                }
                else if selectedFilter == .comment {
                    fetchMovieInfo(kind: "comment", page: 1)
                }
            }
            .onAppear {
                fetchMovieInfo(kind: "bookmark", page: 1)
            }
        }
    }
    
    private func fetchMovieInfo(kind: String, page: Int) {
        Task {
            guard let fetchedMovieInfo: [ItemMovie] = await selectCondtion(kind: kind, page: page) else { return }
            
            var movieInfos: [ForMovieCell] = []
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            for movie in fetchedMovieInfo {
                let formattedReleaseDate = dateFormatter.string(from: movie.releaseDate)
                let movieCell = ForMovieCell(
                    id: movie.id,
                    title: movie.title,
                    posterPath: movie.posterPath,
                    genreIds: [1],
                    releaseDate: formattedReleaseDate
                )
                movieInfos.append(movieCell)
            }
            movieInfo = movieInfos
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


#Preview {
    DiaryListView()
}
