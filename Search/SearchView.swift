//
//  SearchView.swift
//  MovieDiary
//
//  Created by 심연아 on 3/7/25.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack() {
                    ForEach(0 ... 10, id: \.self) { user in
                        VStack {
//                            UserCell()
                            Divider()
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "콘텐츠, 인물, 컬렉션, 유저 검색")
        }
    }
}

#Preview {
    SearchView()
}
