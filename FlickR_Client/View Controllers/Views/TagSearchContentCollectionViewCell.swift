//
//  TagSearchImageCollectionViewCell.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit

class TagSearchContentCollectionViewCell: UICollectionViewCell {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

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

    var userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor().flickr_logoColor()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        return imageView
    } ()

    func setupViews() {
        userNameLabel.text = "UserName"
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 3
        layer.cornerRadius = 7
        contentView.layer.cornerRadius = 7
        contentView.clipsToBounds = true


        let topStackView = UIStackView(arrangedSubviews: [userImageView, userNameLabel])
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        topStackView.alignment = .leading
        topStackView.spacing = 16

        [topStackView, imageView].forEach { contentView.addSubview($0) }

        imageView.frame = frame
        imageView.image = #imageLiteral(resourceName: "flickR_logo")

        NSLayoutConstraint.activate([

            topStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            topStackView.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -5),
//            userImageView.leftAnchor.constraint(equalTo: leftAnchor),
//            userImageView.rightAnchor.constraint(equalTo: userNameLabel.leftAnchor),
//
//            userNameLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor),
//            userNameLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 8),

            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }
}
