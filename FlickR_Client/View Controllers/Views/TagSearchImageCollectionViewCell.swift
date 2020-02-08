//
//  TagSearchImageCollectionViewCell.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit

class TagSearchImageCollectionViewCell: UICollectionViewCell {

    var tagSearch: TagSearch? { didSet { setupViews() } }

    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode =  .scaleAspectFit
        return imageView
    } ()


    func setupViews() {


        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            imageView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
        ])

    }
}
