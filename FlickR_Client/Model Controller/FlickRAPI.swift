//
//  FlickR_API.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import Foundation
import OAuthSwift

class FlickRAPI {
    var myKey = UserDefaults().string(forKey: "myKey_flickr") ?? "44f367e28c0954b2a073d37c1ada9dbe"
    var mySecret =  UserDefaults().string(forKey: "mySecret_flickr") ?? "f07ff5f4115ae5d2"
    let count = 3
    var oauthSwift: OAuthSwift?
    var userName = ""  { didSet  {fetchFavoriteList { _ in }}}
    var favorites: [Favorite] = []
    var noLoginOptIn = false
}

extension FlickRAPI {
    func isInFavorites(searchContent: SearchContent) -> Bool {
        return favorites.filter { $0.id == searchContent.id && $0.farm == searchContent.farm }.isEmpty
    }

    func textHelper(_ text: String) -> String{
        return text.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "+")
    }

    func createPhotoUrlString(with tagSearch: SearchContent, size: String = "m") -> String {
         return "https://farm\(tagSearch.farm).staticflickr.com/\(tagSearch.server)/\(tagSearch.id)_\(tagSearch.secret)_\(size).jpg"
     }

     func createPhotoDetailUrlString(with tagSearch: SearchContent) -> String {
         return "https://www.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=\(myKey)&photo_id=\(tagSearch.id)&secret=\(tagSearch.secret)&format=json&nojsoncallback=1"
     }

     func createFetchCommentsUrlString(id: String) -> String {
         return "https://www.flickr.com/services/rest/?method=flickr.photos.comments.getList&api_key=\(myKey)&photo_id=\(id)&format=json&nojsoncallback=1"
     }

     var serviceFavoiritesAddURL: URL {
         return URL(string: "https://www.flickr.com/services/rest/?method=flickr.favorites.add")!
     }

     var serviceAddCommentURL: URL {
         return URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.comments.addComment")!
     }

     var serviceFetchFavorites: URL {
         return URL(string: "https://www.flickr.com/services/rest/?method=flickr.favorites.getList")!
     }
}

extension FlickRAPI {
    func fetchTagSearch(with tag: String, page: Int = 1, completion: @escaping ([SearchContent]?, Error?) -> ()) {
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(myKey)&tags=\(tag)&per_page=\(count)&format=json&nojsoncallback=1&page=\(page)"
        let url = URL(string: urlString)

        URLSession.shared.dataTask(with: url!) { data, _, error in
            if let error = error {
                completion(nil, error)
            }

            do {
                guard let data = data else { return }
                let resultDict = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                let photos = resultDict["photos"] as! NSDictionary
                let photosList = photos["photo"] as! [NSDictionary]
                let tagSearch = photosList.map { return SearchContent(data: $0) }
                
                completion(tagSearch, nil)
            } catch {
                NSLog("\(error)")
            }

        }.resume()
    }

    func fetchImage(with tagSearch: SearchContent, size: String,completion: @escaping (Data?, Error?) -> ()) {
        let urlString = createPhotoUrlString(with: tagSearch, size: size)
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error, let response = response as? HTTPURLResponse {
                completion(nil, error)
                print(response.statusCode)
            }

            guard let data = data else { return }
            completion(data, nil)
        }.resume()
    }

    func fetchImageDetail(with tagSearch: SearchContent, completion: @escaping (PhotoDetail? , Error?) -> ()) {
        let urlString = createPhotoDetailUrlString(with: tagSearch)
        let url = URL(string: urlString)!

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error, let response = response as? HTTPURLResponse {
                completion(nil, error)
                NSLog("\(response)")
            }

            guard let data = data else {
                completion(nil, NSError())
                return
            }

            do {
                let resultDict = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                let photoDetail = PhotoDetail(data: resultDict)
                completion(photoDetail, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }

    func fetchPhotoComments(id: String, completion: @escaping ([PhotoComment]? , Error?) -> ()) {
        let urlString = createFetchCommentsUrlString(id: id)
        let url = URL(string: urlString)!

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error, let response = response as? HTTPURLResponse {
                completion(nil, error)
                NSLog("\(response)")
            }

            guard let data = data else {
                completion(nil, NSError())
                return
            }

            do {
                let resultDict = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                let result_comments = resultDict["comments"] as! NSDictionary
                if let comments = result_comments["comment"] as? [NSDictionary] {
                    let photocomments = comments.map { return PhotoComment(resultDict: $0) }
                    completion(photocomments, nil)
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }

    func fetchFavoriteList(completion: @escaping (Result<[SearchContent], Error>) -> ()) {
        guard  let oauthSwift = oauthSwift else {
            completion(.failure(NSError()))
            return
        }

        oauthSwift.client.get(serviceFetchFavorites, parameters: ["format": "json"], headers: [:]) { result in
            switch result {
            case .success(let data):
                var str = String(data: data.data, encoding: .utf8)!
                str = str.replacingOccurrences(of: "jsonFlickrApi(", with: "")
                str = str.replacingOccurrences(of: ")", with: "")

                let newData = str.data(using: .utf8)!
                let resultDict = try! JSONSerialization.jsonObject(with: newData, options: []) as! [String: AnyObject]
                let result_photo = resultDict["photos"] as! NSDictionary
                let result_photos = result_photo["photo"] as! [NSDictionary]

                let favorites = result_photos.map {
                    return Favorite(data: $0)
                }

                self.favorites = favorites
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}

