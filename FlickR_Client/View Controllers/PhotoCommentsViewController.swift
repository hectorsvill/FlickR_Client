//
//  PhotoCommentsViewController.swift
//  FlickR_Client
//
//  Created by s on 2/9/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit

class PhotoCommentsViewController: UIViewController {
    var api: FlickR_API!
    var tagSearch: TagSearch?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor().flickr_logoColor()
        fetchPhotoComments()
    }

    private func fetchPhotoComments() {
        guard let tagSearch = tagSearch else { return }

        api.fetchPhotoComments(with: tagSearch.id) { data, error in
            if let error = error {
                NSLog("error: \(error)")
            }

            guard let data = data else { return }
            print(data)

        }


    }



}
