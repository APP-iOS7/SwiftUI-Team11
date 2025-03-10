//
//  popular.swift
//  MovieDiary
//
//  Created by 고요한 on 3/10/25.
//

struct Popular: Identifiable {
    var id: Int
    var genreIds: [String]

    
    enum CodingKeys: CodingKey {
        case id
        case genreIds
    }
}
