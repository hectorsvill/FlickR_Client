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
    var photoDetail: PhotoDetail?
    let tableView = UITableView()
    var metaDataDictionary: [(String, String)] = []

    var photoImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()

    var viewsCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = .clear
        label.textColor = .black
        return label
    }()

    var userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor().flickr_logoColor()
        return label
    }()

    var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .justified
        textView.isEditable = false
        textView.isSelectable = false
        return textView
    }()

    var commentsButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(scale: .large)
        let plusBubbleImage = UIImage(systemName: "plus.bubble", withConfiguration: config)
        button.setImage(plusBubbleImage, for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(likeButtonPressed), for: .touchUpInside)
        return button
    }()

    var likeButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(scale: .large)
        let thumbsupImage = UIImage(systemName: "hand.thumbsup", withConfiguration: config)
        button.setImage(thumbsupImage, for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(commentsButtonPressed), for: .touchUpInside)
        return button
    }()

    @objc func commentsButtonPressed() {
        print("view comments")
    }


    @objc func likeButtonPressed() {
        print("like this image")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewDidLoad()

    }

    private func setupViewDidLoad() {
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        fetchImage()
        setupViews()
        fetchImageDetail()
        setupTagTableView()
    }

    func setupViews() {
        view.backgroundColor = UIColor().flickr_logoColor()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        title = tagSearch?.title
        view.addSubview(photoImageView)
        view.addSubview(tableView)

        let buttonStackView = UIStackView(arrangedSubviews: [likeButton, commentsButton])
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.spacing = 8
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center

        let stackView = UIStackView(arrangedSubviews: [userNameLabel, viewsCountLabel, descriptionTextView, buttonStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        stackView.axis = .vertical
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoImageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            photoImageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            photoImageView.heightAnchor.constraint(equalToConstant: 200),

            stackView.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant:  8),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,constant: 8),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: tableView.topAnchor),

            descriptionTextView.heightAnchor.constraint(equalToConstant: 60),

            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

        ])

    }

    private func fetchImage() {
        guard let tagSearch = tagSearch else { return }

        api.fetchImage(with: tagSearch) { data, error in
            if let error = error {
                NSLog("\(error)")
            }

            guard let data = data else { return }
            let image = UIImage(data: data)!

            DispatchQueue.main.async {
                self.photoImageView.image = image
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
                self.photoDetail = photoDetail
                self.activityIndicator.stopAnimating()
                self.setupViewsWithDetailData(photoDetail: photoDetail)
            }
        })
    }

    private func setupViewsWithDetailData(photoDetail: PhotoDetail) {
        userNameLabel.text = "by: " + (photoDetail.owner_userName.isEmpty ? "Anonymous" : photoDetail.realname)
        descriptionTextView.text = "\(photoDetail.title_content)\n\n" + (photoDetail.description_content.isEmpty ? "No Description" : photoDetail.description_content)
        viewsCountLabel.text = "\(photoDetail.views) views\t"

        metaDataDictionary = [
            ("owner user name: ",  (photoDetail.owner_userName.isEmpty ? "Anonymous" : photoDetail.owner_userName)),
            ("real name:", (photoDetail.realname.isEmpty ? "Anonymous" : photoDetail.realname)),
            ("title:", (photoDetail.title_content.isEmpty ? "No Title" : photoDetail.title_content)),
            ("description:", (photoDetail.description_content.isEmpty ? "No Description" : photoDetail.description_content)),
            ("is favorite:", photoDetail.isFavorite == 0 ? "No" : "Yes" ),
            ("is publinc", photoDetail.ispublic == 0 ? "No" : "Yes" ),
            ("posted", photoDetail.posted),
            ("taken", photoDetail.taken),
            ("last updated:", photoDetail.lastupdate),
            ("views:", photoDetail.views),
            ("can blog:", photoDetail.canblog == 0 ? "No" : "Yes"),
            ("can print:", photoDetail.canprint == 0 ? "No" : "Yes" ),
            ("can Share", photoDetail.canshare == 0 ? "No" : "Yes" ),
        ]

        if photoDetail.isFavorite == 1 {
            let config = UIImage.SymbolConfiguration(scale: .large)
            let thumbsupImage = UIImage(systemName: "hand.thumbsup.fill", withConfiguration: config)
            likeButton.setImage(thumbsupImage, for: .normal)
        }

        tableView.reloadData()
    }
}


extension PhotoDetailViewController: UITableViewDataSource {
    func setupTagTableView() {
        tableView.dataSource = self
        tableView.register(SubTitleTableViewCell.self, forCellReuseIdentifier: "MetaCell")
        tableView.backgroundColor = UIColor().flickr_logoColor()
        tableView.allowsSelection = false
        tableView.separatorStyle = .singleLine
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? metaDataDictionary.count :  (photoDetail?.tags.count ?? 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MetaCell", for: indexPath) as? SubTitleTableViewCell else { return UITableViewCell() }

        if indexPath.section == 1 {
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = photoDetail?.tags[indexPath.row]
        } else if indexPath.section == 0{
            cell.textLabel?.text = metaDataDictionary[indexPath.row].0
            cell.detailTextLabel?.text = metaDataDictionary[indexPath.row].1
            cell.detailTextLabel?.textAlignment = .left
        }

        cell.backgroundColor = UIColor().flickr_logoColor()
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        cell.layer.cornerRadius = 8

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Meta Data" : "Tags"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
}

