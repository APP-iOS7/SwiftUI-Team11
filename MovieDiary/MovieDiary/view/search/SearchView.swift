//
//  SearchView.swift
//  MovieDiary
//
//  Created by 심연아 on 3/7/25.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var forMovicell: [ForMovieCell] = []
    @State private var movieInfo: [MovieResponse]?
    @State private var movieData: [MovieCellData] = (0...10).map { index in
        MovieCellData(
            posterPath: "/sample\(index).jpg",
            title: "Movie Title \(index)",
            releaseDate: Date()
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(forMovicell, id: \.id) { movie in
                        // NavigationLink로 영화 셀을 감싸서 클릭 시 상세 페이지로 이동
                        NavigationLink(destination: posterItemDetailView(movieId: movie.id)) {
                            VStack {
                                MovieCell(movieInfo: movie)
                                Divider()
                            }
                            .padding(5)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "콘텐츠, 인물, 컬렉션, 유저 검색")
            .onChange(of: searchText) {
                Task {
                    movieInfo = await searchRequest(query: searchText, page: 1)
                    forMovicell = []

                    if let results = movieInfo?.first?.results {
                        for movie in results {
                            let movieCell = ForMovieCell(
                                id: movie.id,
                                title: movie.title,
                                posterPath: movie.posterPath,
                                genreIds: movie.genreIds,
                                releaseDate: movie.releaseDate ?? ""
                            )
                            forMovicell.append(movieCell)
                        }
                    }
                }
            }
        }
    }
}

struct MovieCellData: Identifiable, Hashable {
    var id = UUID()
    var posterPath: String
    var title: String
    var releaseDate: Date
}


#Preview {
    SearchView()
}
