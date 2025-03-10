//
//  SearchView.swift
//  MovieDiary
//
//  Created by 심연아 on 3/7/25.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    var item: ItemMovie // 실제 데이터 배열
    @State private var movieData: [MovieCellData] = (0...10).map { index in
        MovieCellData(
            posterPath: "/sample\(index).jpg", // 테스트용 포스터 경로
            title: "Movie Title \(index)", // 샘플 제목
            releaseDate: Date() // 현재 날짜
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(movieData, id: \.id) { movie in // 각 MovieCellData를 순회
                        VStack {
                            // MovieCell에 필요한 데이터를 전달
                            MovieCell(
                                item: item,
                                posterPath: item.posterPath
                            )
                            Divider()
                        }
                        .padding(5)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "콘텐츠, 인물, 컬렉션, 유저 검색")
        }
    }
}

struct MovieCellData: Identifiable, Hashable {
    var id = UUID() // 고유 식별자
    var posterPath: String
    var title: String
    var releaseDate: Date
}
