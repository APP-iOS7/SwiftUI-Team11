

struct ItemDetail: Codable {
    let id: Int
    let backdropPath: String
    let overview: String

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case backdropPath = "BackdropPath"
        case overview = "Overview"
    }
}
