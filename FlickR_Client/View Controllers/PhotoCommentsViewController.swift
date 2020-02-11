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
    let activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Comments"
        view.backgroundColor = UIColor().flickr_logoColor()
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        activityIndicator.color = .systemBlue
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        fetchPhotoComments()
    }

    private func fetchPhotoComments() {
        guard let tagSearch = tagSearch else { return }

        api.fetchPhotoComments(id: tagSearch.id) { photoComments, error in
            if let error = error {
                NSLog("error: \(error)")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }

            guard let photoComments = photoComments else { return }
            DispatchQueue.main.async {
                print(photoComments)
                self.activityIndicator.stopAnimating()
            }

        }


    }



}
