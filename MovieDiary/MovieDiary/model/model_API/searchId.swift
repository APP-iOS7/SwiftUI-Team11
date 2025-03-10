

struct SearchResults: Codable {
    let movieDetails: [ItemMovie]
    let itemDetails: [ItemDetail]

    enum CodingKeys: String, CodingKey {
        case movieDetails = "movie_details"
        case itemDetails = "item_details"
    }
}
