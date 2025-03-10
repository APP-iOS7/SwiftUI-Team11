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
    
    // 날짜 변환 메서드 추가
    static func dateFromString(_ dateString: String) -> Date {
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
        
        // 변환 실패 시 현재 날짜 반환
        return Date()
    }

    // 기존 init(from decoder:) 메서드 유지
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // ID 디코딩 (여러 형식 대응)
        if let id = try? container.decode(Int.self, forKey: .id) {
            self.id = id
        } else if let idString = try? container.decode(String.self, forKey: .id), let parsedId = Int(idString) {
            self.id = parsedId
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "ID를 디코딩할 수 없습니다."))
        }
        
        // 다른 필드들도 유사하게 유연하게 디코딩
        title = (try? container.decode(String.self, forKey: .title)) ?? ""
        posterPath = (try? container.decode(String.self, forKey: .posterPath)) ?? ""
        
        // GenreIds 유연하게 디코딩
        if let genreIds = try? container.decode([String].self, forKey: .genreIds) {
            self.genreIds = genreIds
        } else if let genreIdsDict = try? container.decode([String: String].self, forKey: .genreIds) {
            self.genreIds = Array(genreIdsDict.values)
        } else {
            self.genreIds = []
        }
        
        // 날짜 디코딩 유연하게
        if let releaseDateString = try? container.decode(String.self, forKey: .releaseDate) {
            releaseDate = Self.dateFromString(releaseDateString)
        } else {
            releaseDate = Date()
        }
        
        comment = (try? container.decode(String.self, forKey: .comment)) ?? ""
        rate = (try? container.decode(Float.self, forKey: .rate)) ?? 0.0
        isBookmarked = (try? container.decode(Bool.self, forKey: .isBookmarked)) ?? false
    }
}
