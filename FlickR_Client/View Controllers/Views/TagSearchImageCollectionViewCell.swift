//
//  TagSearchImageCollectionViewCell.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit

class TagSearchImageCollectionViewCell: UICollectionViewCell {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    } ()

    func setupViews() {
        layer.cornerRadius = 6
        layer.borderWidth = 1
        contentView.addSubview(imageView)

        imageView.frame = frame
        imageView.image = #imageLiteral(resourceName: "flickR_logo")

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
        ])
    }
}
