//
//  MoviePosterView.swift
//  MovieDiary
//
//  Created by 심연아 on 3/7/25.
//

import SwiftUI

struct MoviePosterImageView: View {
    @Binding var testBinding : String
    var body: some View {
        Image(testBinding)
            .resizable()
            .scaledToFill()
            .frame(width: 90, height: 135)
    }
}

#Preview {
    @Previewable @State var a: String = "testImage"
    MoviePosterImageView(testBinding: $a)
}
