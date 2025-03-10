import Foundation

func encodingSelectData(_ data: Data?) -> [ItemMovie]? {
    do {
        let resultToFormData: [ItemMovie] = try JSONDecoder().decode([ItemMovie].self, from: data ?? Data())
        return resultToFormData
    }
    catch {
        print("error: \(error)")
    }
    return nil
}

func encodingSearchData(_ data: Data?) -> [MovieResponse]? {
    do {
        let resultToFormData: [MovieResponse]
        
        if let decodedArray = try? JSONDecoder().decode([MovieResponse].self, from: data ?? Data()) {
            resultToFormData = decodedArray
        } else {
            let decodedObject = try JSONDecoder().decode(MovieResponse.self, from: data ?? Data())
            resultToFormData = [decodedObject]
        }
        
        return resultToFormData
    } catch {
        print("error: \(error)")
    }
    return nil
}

func encodingSearchIdData(_ data: Data?) -> SearchResults? {
    do {
        let resultToFormData: SearchResults = try JSONDecoder().decode(SearchResults.self, from: data ?? Data())
        return resultToFormData
    }
    catch {
        print("error: \(error)")
    }
    return nil
}
