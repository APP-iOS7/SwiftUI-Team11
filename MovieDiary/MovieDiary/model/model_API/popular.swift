

struct Popular: Identifiable {
    var id: Int
    var genreIds: [String]

    
    enum CodingKeys: CodingKey {
        case id
        case genreIds
    }
}
