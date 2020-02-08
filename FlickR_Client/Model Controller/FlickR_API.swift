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
    var mySecret = UserDefaults().string(forKey: "mySecret_flickr") ?? ""
    let count = 5
    var tagSearch: [TagSearch] = []

    func fetchTagSearch(with tag: String, page: Int = 1, completion: @escaping ([TagSearch]?, Error?) -> ()) {
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(myKey)&tags=\(tag)&per_page=\(count)&format=json&nojsoncallback=1"
        let url = URL(string: urlString)

        URLSession.shared.dataTask(with: url!) { data, _, error in
            if let error = error {
                completion(nil, error)
            }

            guard let data = data else { return }

            do {

                let resultDict = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                let photos = resultDict["photos"] as! NSDictionary
                let photosList = photos["photo"] as! [NSDictionary]
                let tagSearch = photosList.map {
                    return TagSearch(data: $0)
                }
                self.tagSearch = tagSearch
                completion(tagSearch, nil)
            } catch {
                NSLog("\(error)")
            }

        }.resume()
    }

    func fetchImage(with tagSearch: TagSearch, completion: @escaping (Data?, Error?) -> ()) {
        let urlString = createPhotoUrlString(with: tagSearch)
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

    func createPhotoUrlString(with tagSearch: TagSearch) -> String {
        "https://farm\(tagSearch.farm).staticflickr.com/\(tagSearch.server)/\(tagSearch.id)_\(tagSearch.secret)_m.jpg"
    }

    func createPhotoDetailUrlString(with tagSearch: TagSearch) -> String {
        "https://www.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=\(myKey)&photo_id=\(tagSearch.id)&secret=\(tagSearch.secret)&format=json&nojsoncallback=1"
    }
}
