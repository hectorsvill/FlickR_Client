//
//  ViewController.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let api = FlickR_API()
    override func viewDidLoad() {
        super.viewDidLoad()


        let str = "  The office us".trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "+")

        api.fetchTagSearch(with: str) { tagSearch, error in
            if let error = error {
                NSLog("\(error)")
            }
            guard let t = tagSearch else { return }
            print(t.count)

            self.fetchImage()
            self.fetchImageDetail()

        }
    }

    private func fetchImage() {
        let tagsearch = api.tagSearch[0]
        api.fetchImage(with: tagsearch) { data, error in
            if let error = error {
                NSLog("\(error)")
            }
            guard let data = data else { return }

        }

    }

    private func fetchImageDetail() {
        let tagsearch = api.tagSearch[0]
        api.fetchImageDetail(with: tagsearch) { pd, error in
            if let error = error {
                NSLog("\(error)")

            }

            guard let pd = pd else { return }
            print("\(pd.description_content)")

        }
    }

}

