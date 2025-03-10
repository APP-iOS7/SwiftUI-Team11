//
//  MovieCell.swift
//  MovieDiary
//
//  Created by 심연아 on 3/7/25.
//

import SwiftUI

struct MovieCell: View {
    @State var testBinding : String = ""
    var body: some View {
        HStack(spacing: 10) {
            MoviePosterImageView(testBinding:$testBinding)
            
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

