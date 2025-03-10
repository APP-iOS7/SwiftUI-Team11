//
//  MovieCell.swift
//  MovieDiary
//
//  Created by 심연아 on 3/7/25.
//

import SwiftUI

struct MovieCell: View {
    var body: some View {
        HStack(spacing: 10) {
            MoviePosterImageView()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Movie Title")
                    .fontWeight(.bold)
                
                Text("year/kinds")
                    .font(.footnote)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        
    }
}

#Preview {
    MovieCell()
}
