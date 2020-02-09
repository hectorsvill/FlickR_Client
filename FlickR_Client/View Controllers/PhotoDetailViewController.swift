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
    let tagTableView = UITableView()

    var photoImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()

    var viewsCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
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
        textView.textAlignment = .left

        textView.isEditable = false
        textView.isSelectable = false
        return textView
    }()

    var commentsButton: UIButton = {
        let button = UIButton()


        return button
    }()

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
        tagTableView.translatesAutoresizingMaskIntoConstraints = false
        title = tagSearch?.title
        view.addSubview(photoImageView)
//        view.addSubview(userNameLabel)
//        view.addSubview(descriptionTextView)
        //        view.addSubview(viewsCountLabel)
        view.addSubview(tagTableView)

        let stackView = UIStackView(arrangedSubviews: [userNameLabel, viewsCountLabel, descriptionTextView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        stackView.axis = .vertical
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoImageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            photoImageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            photoImageView.heightAnchor.constraint(equalToConstant: 200),

            stackView.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant:  -8),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: tagTableView.topAnchor),

//            viewsCountLabel.bottomAnchor.constraint(equalTo: photoImageView.bottomAnchor),
//            viewsCountLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
//
//            userNameLabel.heightAnchor.constraint(equalToConstant: 24),
//            userNameLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 8),
//            userNameLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
//            userNameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
//            userNameLabel.heightAnchor.constraint(equalToConstant: 24),
//
            descriptionTextView.heightAnchor.constraint(equalToConstant: 60),
//            descriptionTextView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
//            descriptionTextView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
//            descriptionTextView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
//
//            tagTableView.heightAnchor.constraint(equalToConstant: 120),
            tagTableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8),
            tagTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tagTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tagTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

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
        tagTableView.reloadData()

        print("isFavorite: ", photoDetail.isFavorite)
    }
}


extension PhotoDetailViewController: UITableViewDataSource {
    func setupTagTableView() {
        tagTableView.dataSource = self
        tagTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TagCell")
        tagTableView.backgroundColor = UIColor().flickr_logoColor()
        tagTableView.allowsSelection = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoDetail?.tags.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tagTableView.dequeueReusableCell(withIdentifier: "TagCell", for: indexPath)
        cell.textLabel?.text = photoDetail?.tags[indexPath.row]
        cell.backgroundColor = UIColor().flickr_logoColor()
        cell.layer.cornerRadius = 8
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tags"
    }



}
