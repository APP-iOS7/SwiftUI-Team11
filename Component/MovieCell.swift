//
//  MovieCell.swift
//  MovieDiary
//
//  Created by 심연아 on 3/7/25.
//

import SwiftUI

struct MovieCell: View {
    var body: some View {
        HStack {
            MoviePosterView()
            
            VStack(alignment: .leading) {
                Text("Movie Title")
                    .fontWeight(.bold)
                
                Text("year/kinds")
                    .font(.footnote)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        
    }
}

#Preview {
    MovieCell()
}
