import Foundation

struct ItemMovie: Identifiable, Codable {
    var id: Int
    var title: String
    var posterPath: String
    var genreIds: [String]
    var releaseDate: Date
    var comment: String
    var rate: Float
    var isBookmarked: Bool

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case title = "Title"
        case posterPath = "PosterPath"
        case genreIds = "GenreIds"
        case releaseDate = "ReleaseDate"
        case comment = "Comment"
        case rate = "Rate"
        case isBookmarked = "IsBookmarked"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        posterPath = try container.decode(String.self, forKey: .posterPath)
        genreIds = try container.decode([String].self, forKey: .genreIds)
        
        let dateString = try container.decode(String.self, forKey: .releaseDate)
        releaseDate = try ItemMovie.dateFromString(dateString)
        
        comment = try container.decode(String.self, forKey: .comment)
        rate = try container.decode(Float.self, forKey: .rate)
        isBookmarked = try container.decode(Bool.self, forKey: .isBookmarked)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(posterPath, forKey: .posterPath)
        try container.encode(genreIds, forKey: .genreIds)
        try container.encode(ItemMovie.stringFromDate(releaseDate), forKey: .releaseDate)
        try container.encode(comment, forKey: .comment)
        try container.encode(rate, forKey: .rate)
        try container.encode(isBookmarked, forKey: .isBookmarked)
    }
    
    static func dateFromString(_ dateString: String) throws -> Date {
        let formats = ["yyyy-MM-dd", "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd'T'HH:mm:ssZ"]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "UTC")

        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [],
            debugDescription: "날짜 형식이 맞지 않습니다. \(dateString)"))
    }

    static func stringFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: date)
    }
}
