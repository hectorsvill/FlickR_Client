//
//  FlickR_API.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import Foundation

class FlickR_API {
    var myKey = UserDefaults().string(forKey: "myKey_flickr") ?? ""
    var mySecret =  UserDefaults().string(forKey: "mySecret_flickr") ?? ""
    let count = 12
    var authToken = ""
    var authTokenSecret = ""

    func fetchTagSearch(with tag: String, page: Int = 1, completion: @escaping ([TagSearch]?, Error?) -> ()) {
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
                let tagSearch = photosList.map { return TagSearch(data: $0) }
                
                completion(tagSearch, nil)
            } catch {
                NSLog("\(error)")
            }

        }.resume()
    }

    func fetchImage(with tagSearch: TagSearch, size: String,completion: @escaping (Data?, Error?) -> ()) {
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

    func fetchImageDetail(with tagSearch: TagSearch, completion: @escaping (PhotoDetail? , Error?) -> ()) {
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


    func createPhotoUrlString(with tagSearch: TagSearch, size: String = "m") -> String {
        "https://farm\(tagSearch.farm).staticflickr.com/\(tagSearch.server)/\(tagSearch.id)_\(tagSearch.secret)_\(size).jpg"
    }

    func createPhotoDetailUrlString(with tagSearch: TagSearch) -> String {
        "https://www.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=\(myKey)&photo_id=\(tagSearch.id)&secret=\(tagSearch.secret)&format=json&nojsoncallback=1"
    }

    func createFetchCommentsUrlString(id: String) -> String {
        "https://www.flickr.com/services/rest/?method=flickr.photos.comments.getList&api_key=\(myKey)&photo_id=\(id)&format=json&nojsoncallback=1"
    }

    func createFavoriteUrlString(action: String = "add", tagSearch: TagSearch) -> String {
        "https://www.flickr.com/services/rest/?method=flickr.favorites.\(action)&api_key=\(myKey)&photo_id=\(tagSearch.id)&format=json&nojsoncallback=1&auth_token=\(authToken)" //"&api_sig=dcaf85570b578b3c917757dd96c174f4"
    }
    //https://www.flickr.com/services/rest/?method=flickr.favorites.remove&api_key=7d336d9e7c4d1b31cbba0a429216afc4&photo_id=9576279208&format=json&nojsoncallback=1&auth_token=72157713063788528-a60cf9cb11ae6ebb&api_sig=6e834e0bc780157cefc08b4b46765cef
}
