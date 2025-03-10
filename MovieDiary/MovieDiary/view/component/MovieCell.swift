//
//  MovieCell.swift
//  MovieDiary
//
//  Created by 심연아 on 3/7/25.
//

import SwiftUI

struct MovieCell: View {
    var item: ItemMovie
    let posterPath: String

    var body: some View {
        HStack(spacing: 10) {
            // 영화 포스터
            MoviePosterImageView(posterPath: item.posterPath)
                .frame(width: 90, height: 135)

            // 제목과 날짜
            VStack(alignment: .leading, spacing: 5) {
                Text(item.title) // 영화 제목
                    .fontWeight(.bold)
                    .font(.title3)

                Text(formatDate(item.releaseDate)) // 개봉 날짜 포맷
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
    }



#Preview {
   MovieCell()
}
