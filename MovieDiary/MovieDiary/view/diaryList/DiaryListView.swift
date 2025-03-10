//
//  DiaryListView.swift
//  MovieDiary
//
//  Created by 심연아 on 3/7/25.
//

import SwiftUI

struct DiaryListView: View {
    @State private var selectedFilter: DiaryListFilter = .wish
    @Namespace var animation
    
    private var filterBarWidth: CGFloat {
        let count = CGFloat(DiaryListFilter.allCases.count)
        return UIScreen.main.bounds.width / count - 16
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 12) {
                        //fullname and username
                        VStack(alignment: .leading, spacing: 4) {
                            Text("심연아")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("yeon_ah")
                                .font(.subheadline)
                        }
                        
                    }
                    Spacer()
                    
                    CircularProfileImageView()
                }

                
                // user content list view
                VStack {
                    HStack {
                        ForEach(DiaryListFilter.allCases) { filter in
                            VStack {
                                Text(filter.title)
                                    .font(.subheadline)
                                    .fontWeight(selectedFilter == filter ? .semibold : .regular)
                                
                                if selectedFilter == filter {
                                    Rectangle()
                                        .foregroundColor(.black)
                                        .frame(width: filterBarWidth, height: 1)
                                        .matchedGeometryEffect(id: "item", in: animation)
                                } else {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: filterBarWidth, height: 1)
                                }
                            }
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedFilter = filter
                                }
                            }
                        }
                    }
                    LazyVStack {
                        ForEach(0 ... 10, id: \.self) { _ in
                            MovieCell()
                            Divider()
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .padding(.horizontal)
    }
}

struct CircularProfileImageView: View {
    var body: some View {
        Image("poster1")
            .resizable()
            .scaledToFill()
            .frame(width: 50, height: 50)
            .clipShape(Circle())
    }
}

#Preview {
    DiaryListView()
}
