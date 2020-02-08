//
//  FlickR_API.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import Foundation

class FlickR_API {
    let myKey = "170edde37b27d9e8f912f3b5183484f2"
    let mySecret = "8c513ef223b12070"
    let count = 10
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
        let urlString = "https://farm\(tagSearch.farm).staticflickr.com/\(tagSearch.server)/\(tagSearch.id)_\(tagSearch.secret)_c.jpg"
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
        let urlString = createPhotUrlString(with: tagSearch)
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

    func createPhotUrlString(with tagSearch: TagSearch) -> String {
        "https://www.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=\(myKey)&photo_id=\(tagSearch.id)&secret=\(tagSearch.secret)&format=json&nojsoncallback=1"
    }

}
