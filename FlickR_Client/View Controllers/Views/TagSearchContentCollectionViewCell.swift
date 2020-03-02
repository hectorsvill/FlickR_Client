//
//  TagSearchImageCollectionViewCell.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit

protocol TagSearchContentCollectionDelegate: AnyObject {
    func infoButtonPressed(_ searchContent: SearchContent)
}

class TagSearchContentCollectionViewCell: UICollectionViewCell {
    var delegate: TagSearchContentCollectionDelegate?
    var searchContent: SearchContent? { didSet { setupViews() } }
    var api: FlickRAPI!


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
        button.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)

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

    var topStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading
        stackView.spacing = 16
        return stackView
    }()

    func setupViews() {
        guard let searchContent = searchContent else { return }
        contentView.layer.cornerRadius = 7
        contentView.clipsToBounds = true

        titleLabel.text = searchContent.title.trimmingCharacters(in: .whitespaces).isEmpty ? "Title" : searchContent.title
        topStackView.addArrangedSubview(titleLabel)

        imageView.frame = frame
        imageView.image = #imageLiteral(resourceName: "flickR_logo")

        [topStackView, imageView, infoButton,likeButton].forEach { contentView.addSubview($0) }

        activateConstraints()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
//            topStackView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 8),
//            topStackView.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -5),

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

    @objc func infoButtonPressed() {
        guard let searchContent = searchContent else { return }

        delegate?.infoButtonPressed(searchContent)
    }

}
