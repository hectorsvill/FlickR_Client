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

    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
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
        fetchImageDetail()
        setupTagTableView()
    }


    func setupViews() {
        view.backgroundColor = UIColor().flickr_logoColor()
        tagTableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(photoImageView)
        view.addSubview(titleLabel)
        view.addSubview(tagTableView)
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoImageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            photoImageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            photoImageView.heightAnchor.constraint(equalToConstant: 300),

//            tagsLabel.bottomAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: -8),
//            tagsLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
//            tagsLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),

            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 8),
            titleLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),

            tagTableView.heightAnchor.constraint(equalToConstant: 120),
            tagTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            tagTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tagTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),

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
        self.titleLabel.text = photoDetail.owner_userName.isEmpty ? "Anonymous" : photoDetail.realname
        tagTableView.reloadData()
    }
}


extension PhotoDetailViewController: UITableViewDataSource {

    func setupTagTableView() {
        tagTableView.dataSource = self
        tagTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TagCell")
        tagTableView.backgroundColor = UIColor().flickr_logoColor()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoDetail?.tags.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tagTableView.dequeueReusableCell(withIdentifier: "TagCell", for: indexPath)
        cell.textLabel?.text = photoDetail?.tags[indexPath.row]
        cell.backgroundColor = UIColor().flickr_logoColor()
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tags"
    }



}
