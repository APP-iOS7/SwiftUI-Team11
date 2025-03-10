//
//  MoviePosterView.swift
//  MovieDiary
//
//  Created by 심연아 on 3/7/25.
//

import SwiftUI

struct MoviePosterImageView: View {
    let posterPath: String // 단순 String 값으로 수정
    @State private var item: [ItemMovie] = []
    
    var body: some View {
        if let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 90, height: 135)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 90, height: 135)
                        .clipped()
                case .failure:
                    Color.gray
                        .frame(width: 90, height: 135)
                        .overlay(Text("Error").foregroundColor(.white))
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Color.red
                .frame(width: 90, height: 135)
                .overlay(Text("Invalid URL").foregroundColor(.white))
        }
    }
}

// #Preview {
// //    @Previewable @State var testPosterPath: String = "/9ViCYfZ0whpwtKbM2WJP5PfsG2x.jpg" // 상태 변수 선언
// //    MoviePosterImageView(posterPath: $testPosterPath) // Binding 전달
//    MoviePosterImageView(posterPath: .constant("https://image.tmdb.org/t/p/w500/7hThYJ0yBzclKviPxBt5UB94zNT.jpg"))
// }



