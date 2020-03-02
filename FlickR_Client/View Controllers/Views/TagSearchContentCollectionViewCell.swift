//
//  TagSearchImageCollectionViewCell.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit

protocol TagSearchContentCollectionDelegate {
    func infoButtonPressed(_ searchContent: SearchContent)
    func likeButtonPressed(_ searchContent: SearchContent)
}

class TagSearchContentCollectionViewCell: UICollectionViewCell {
    var delegate: TagSearchContentCollectionDelegate?
    var searchContent: SearchContent? { didSet { setupViews() } }
    var api: FlickRAPI!
    var isFavorite = false

    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor().flickr_logoColor()
        label.textColor = .systemGray
        label.font = UIFont.boldSystemFont(ofSize: 13)
        return label
    }()

    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor().flickr_logoColor()
        imageView.contentMode =  .scaleToFill
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    var infoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .systemGray
        button.backgroundColor = UIColor().flickr_logoColor()
        let listImageName =  "list.dash"
        let image = UIImage(systemName: listImageName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .large))
        button.setImage(image, for: .normal)
        return button
    }()

    var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .systemGray
        button.backgroundColor = UIColor().flickr_logoColor()
        return button
    }()

    func setupViews() {
        contentView.layer.cornerRadius = 7
        contentView.clipsToBounds = true

        imageView.frame = frame
        imageView.image = #imageLiteral(resourceName: "flickR_logo")

        let doubletap = UITapGestureRecognizer(target: self, action: #selector(likeImage))
        doubletap.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubletap)
        infoButton.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(likeImage), for: .touchUpInside)

        [imageView, infoButton,likeButton]
            .forEach { contentView.addSubview($0) }

        activateConstraints()
    }

    private func activateConstraints() {
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor),

            infoButton.topAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.bottomAnchor, constant: 5),
            infoButton.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 5),

            likeButton.topAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.bottomAnchor, constant:  5),
            likeButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -5),
        ])
    }

    @objc func likeImage() {
        guard let searchContent = searchContent else { return }
        isFavorite.toggle()
        delegate?.likeButtonPressed(searchContent)
    }

    @objc func infoButtonPressed() {
        guard let searchContent = searchContent else { return }
        delegate?.infoButtonPressed(searchContent)
    }
}
