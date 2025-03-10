//
//  ContentView.swift
//  MovieDiary
//
//  Created by 고요한 on 3/6/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        posterItemDetailView(movieId: 2222)
    }

}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
