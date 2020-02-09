//
//  PhotoDetailViewController.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit

final class PhotoDetailViewController: UIViewController {
    var api: FlickR_API!
    var tagSearch: TagSearch?
    let activityIndicator = UIActivityIndicatorView()

    var photoImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()



    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        fetchImage()
        setupViews()
    }


    func setupViews() {

        view.backgroundColor = UIColor().flickr_logoColor()
        view.addSubview(photoImageView)


        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoImageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            photoImageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            photoImageView.heightAnchor.constraint(equalToConstant: 300)

        ])

    }

    private func fetchImage() {
        guard let tagSearch = tagSearch else { return }

        title = tagSearch.title
        api.fetchImage(with: tagSearch) { data, error in
            if let error = error {
                NSLog("\(error)")
            }

            guard let data = data else { return }
            let image = UIImage(data: data)!
            print(image)

            DispatchQueue.main.async {
                self.photoImageView.image = image
                self.activityIndicator.stopAnimating()
            }
        }


    }

    private func fetchImageDetail() {
        guard let tagSearch = tagSearch else { return }
        api.fetchImageDetail(with: tagSearch, completion: { photoDetail, error in
            if let error = error {
                NSLog("\(error)")
                // alert user and dismiss page
            }

            guard let photoDetail = photoDetail else { return }
            DispatchQueue.main.async {
                print(photoDetail)
                self.activityIndicator.stopAnimating()
            }
        })

    }


}
