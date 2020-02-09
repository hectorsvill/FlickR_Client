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
        imageView.contentMode = .redraw
        return imageView
    } ()

    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    } ()

    func setupViews() {
        guard let tagSearch = tagSearch else { return }
        backgroundColor = .systemGray3
        self.contentView.addSubview(imageView)
        addSubview(titleLabel)
        titleLabel.text = tagSearch.title
        imageView.frame = frame
        imageView.image = #imageLiteral(resourceName: "flickR_logo")
        NSLayoutConstraint.activate([

            imageView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),

            titleLabel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -8),
            titleLabel.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 8),
            titleLabel.heightAnchor.constraint(equalToConstant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])

    }
}
