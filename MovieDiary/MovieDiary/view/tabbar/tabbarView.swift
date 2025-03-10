//
//  TabBarView.swift
//  MovieDiary
//
//  Created by 심연아 on 3/7/25.
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0
    @State private var showCreateThreadView = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                    Text("홈")
                }
                .onAppear { selectedTab = 0 }
                .tag(0)
            
            DiaryListView()
                .tabItem {
                    Image(systemName: "plus")
                        .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                    Text("영화록")
                }
                .onAppear { selectedTab = 1 }
                .tag(1)
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                        .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                    Text("검색")
                }
                .onAppear { selectedTab = 2 }
                .tag(2)

        }
//        .onChange(of: selectedTab) { oldValue, newValue in
//            showCreateThreadView = newValue == 2
//        }

//        .sheet(isPresented: $showCreateThreadView, onDismiss: {
//            selectedTab = 0
//        }, content: {
//            createCommentView()
//            //여길 이제 CommentView로 바꿔주면 됩니다.
//        })
        .tint(.black)
    }
}

#Preview {
    TabBarView()
}
