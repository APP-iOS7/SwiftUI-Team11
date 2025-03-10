//
//  DiaryListFilter.swift
//  MovieDiary
//
//  Created by 심연아 on 3/7/25.
//

import Foundation

enum DiaryListFilter: Int, CaseIterable, Identifiable {
    case wish
    case comment

    var title: String {
        switch self {
        case .wish: return "Wish"
        case .comment: return "Comment"
        }
    }
    
    var id: Int { return self.rawValue }
}

