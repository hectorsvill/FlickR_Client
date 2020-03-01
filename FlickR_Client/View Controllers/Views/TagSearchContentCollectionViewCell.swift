//
//  TagSearchImageCollectionViewCell.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit

class TagSearchContentCollectionViewCell: UICollectionViewCell {

    var tagSearch: searchContent? { didSet { setupViews() } }

    var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor().flickr_logoColor()
//        imageView.layer.borderColor = UIColor.white.cgColor
//        imageView.layer.borderWidth = 3
//        imageView.layer.cornerRadius = imageView.frame.size.height / 2
        imageView.image = UIImage(systemName: "person.fill")
        return imageView
    }()

    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor().flickr_logoColor()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "title"
        return label
    }()

    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor().flickr_logoColor()
        imageView.contentMode =  .scaleToFill
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()

    func setupViews() {
        guard let tagSearch = tagSearch else { return }

        titleLabel.text = tagSearch.title
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 3
        layer.cornerRadius = 7
        contentView.layer.cornerRadius = 7
        contentView.clipsToBounds = true


        let topStackView = UIStackView(arrangedSubviews: [userImageView, titleLabel])
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        topStackView.alignment = .leading
        topStackView.spacing = 16

        [topStackView, imageView].forEach { contentView.addSubview($0) }

        imageView.frame = frame
        imageView.image = #imageLiteral(resourceName: "flickR_logo")

        NSLayoutConstraint.activate([

            topStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 5),
            topStackView.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -5),

            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }
}
