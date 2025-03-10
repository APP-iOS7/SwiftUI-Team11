import Foundation

func makeRequest(urlPath: String, method: String) -> URLRequest? {
    guard let url = URL(string: urlPath) else { return nil }
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    return request
}

func sendRequset(request: URLRequest, data: Data?) async -> Data? {
    var request = request
    if let data = data {
        do {
            request.httpBody = data
            let (data_r, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { return nil }
            switch httpResponse.statusCode {
            case 200..<300:
                return data_r
            case 300..<400:
                print("똑바로 해")
            case 400..<500:
                print("잘좀 해")
            default:
                print("서버 탓 하셈 ㅅㄱ")
                return nil
            }
        }
        catch {
            print(error)
        }
    }
    return nil
}

func selectRequest(model: String, page: Int = 1, genre_ids: String? = "", name: String? = "") async -> [ItemMovie]? {
    var url = API_URL + "/select?model=\(model)&page=\(page)"
    if genre_ids != "" {
        do {
            let jsonString : [String] = [genre_ids!]
            let jsonData = try JSONEncoder().encode(jsonString)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                if let encodedString = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    url += "&genre_ids=\(String(describing: encodedString))"
                    print(url)
                }
            }
        } catch {
            print("genre_ids encoding error")
        }
    }
    if name != "" {
        url += "&name=\(String(describing: name))"
    }
    if let request =  makeRequest(urlPath: url, method: "GET") {
        let result = await sendRequset(request: request, data: Data())
        return encodingSelectData(result)
    }
    else {
        return nil
    }
}

func searchRequest(query: String, page: Int = 1) async -> [MovieResponse]? {
    let url = API_URL + "/search?query=\(query)&page=\(page)"
    if let request =  makeRequest(urlPath: url, method: "GET") {
        let result = await sendRequset(request: request, data: Data())
        return encodingSearchData(result)
    }
    else {
        return nil
    }
}

func selectCondtion(kind: String, page: Int = 1) async -> [ItemMovie]? {
    var url = API_URL + "/selectCondition?&page=\(page)"
    if kind == "bookmark" {
        url += "&kind=\(kind)"
    } else if kind == "comment" {
        url += "&kind=\(kind)"
    }
    if let request =  makeRequest(urlPath: url, method: "GET") {
        let result = await sendRequset(request: request, data: Data())
        return encodingSelectData(result)
    }
    else {
        return nil
    }
}

func updateRequest(model: String, id: Int, rate: Float = -1, isBookmarked: Bool? = nil , comment: String = "") async {
    var url = API_URL + "/update?model=\(model)&id=\(id)"
    if rate != -1 {
        url += "&rate=\(String(describing: rate))"
    }
    if isBookmarked != nil {
        url += "&is_bookmarked=\(String(describing: isBookmarked!))"
    }
    if comment != "" {
        url += "&comment=\(String(describing: comment))"
    }
    if let request =  makeRequest(urlPath: url, method: "GET") {
        let _ = await sendRequset(request: request, data: Data())
    }
    else {
        print("fail to make request")
    }
}

func serchIDRequest(id: Int) async -> SearchResults? {
    let url = API_URL + "/searchId?movie_id=\(id)"
    if let request =  makeRequest(urlPath: url, method: "GET") {
        let result = await sendRequset(request: request, data: Data())
        return encodingSearchIdData(result)
    }
    else {
        return nil
    }
}


