

struct ItemDetail: Identifiable, Codable {
    var id: Int
    var backdropPath: String
    var overview: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case backdropPath
        case overview
    }
}
