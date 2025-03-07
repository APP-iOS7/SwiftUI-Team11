//
//  MoviePosterView.swift
//  MovieDiary
//
//  Created by 심연아 on 3/7/25.
//

import SwiftUI

struct MoviePosterView: View {
    var body: some View {
        Image("poster1")
            .resizable()
            .scaledToFill()
            .frame(width: 90, height: 135)
    }
}

#Preview {
    MoviePosterView()
}
