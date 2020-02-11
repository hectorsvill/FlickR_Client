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
    var photoComments: [PhotoComment] = []

    var photoImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()

    var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["META", "Comments"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentControlDidChange), for: .valueChanged)
        return control
    }()

    var commentsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(scale: .large)
        let plusBubbleImage = UIImage(systemName: "plus.bubble", withConfiguration: config)
        button.setImage(plusBubbleImage, for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = UIColor().flickr_logoColor()
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(commentsButtonPressed), for: .touchUpInside)
        return button
    }()

    var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let thumbsupImage = UIImage(systemName: "hand.thumbsup", withConfiguration: symbolConfiguration)
        button.setImage(thumbsupImage, for: .normal)
        button.backgroundColor = .clear
        button.tintColor = .black
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(likeButtonPressed), for: .touchUpInside)
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Like", style: .plain, target: self, action: #selector(likeButtonPressed))
    }

    private func setupViewDidLoad() {
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        activityIndicator.color = .systemBlue
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        fetchImage()
        setupViews()
        fetchPhotoDetail()
        setupTagTableView()

//        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
//        let thumbsupImage = UIImage(systemName: "hand.thumbsup", withConfiguration: symbolConfiguration)
//        navigationController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: thumbsupImage, style: .plain, target: self, action: #selector(likeButtonPressed))
    }
}

extension PhotoDetailViewController {
    func setupViews() {
        view.backgroundColor = UIColor().flickr_logoColor()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photoImageView)
        view.addSubview(tableView)

//        let buttonStackView = UIStackView(arrangedSubviews: [commentsButton, likeButton])
//        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
//        buttonStackView.axis = .horizontal
//        buttonStackView.spacing = 8
//        buttonStackView.alignment = .fill
//        buttonStackView.distribution = .fillEqually
//        buttonStackView.backgroundColor = UIColor().flickr_logoColor()
//
//        let stackView = UIStackView(arrangedSubviews: [userNameLabel, viewsCountLabel, descriptionTextView, buttonStackView])
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.spacing = 8
//        stackView.axis = .vertical
//        stackView.backgroundColor = UIColor().flickr_logoColor()
//        view.addSubview(stackView)

        view.addSubview(segmentedControl)
        view.addSubview(likeButton)
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoImageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            photoImageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            photoImageView.heightAnchor.constraint(equalToConstant: 325),
            segmentedControl.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 8),
            segmentedControl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            segmentedControl.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
//            segmentedControl.widthAnchor.constraint(equalToConstant: 40)
//            stackView.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant:  8),
//            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,constant: 8),
//            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
//            stackView.bottomAnchor.constraint(equalTo: tableView.topAnchor),
////            descriptionTextView.heightAnchor.constraint(equalToConstant: 60),
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    @objc func commentsButtonPressed() {

     }

    @objc func likeButtonPressed() {
        let urlString = api.createFavoriteUrlString(tagSearch: tagSearch!)
        print(urlString)
    }

    @objc func segmentControlDidChange() {
        tableView.reloadData()
    }

    private func fetchImage() {
        guard let tagSearch = tagSearch else { return }

        api.fetchImage(with: tagSearch, size: "z") { data, error in
            if let error = error {
                NSLog("\(error)")
            }

            guard let data = data else { return }
            let image = UIImage(data: data)!

            DispatchQueue.main.async {
                self.photoImageView.image = image
                self.activityIndicator.stopAnimating()
            }
        }
    }

    private func fetchPhotoDetail() {
        guard let tagSearch = tagSearch else { return }
        api.fetchImageDetail(with: tagSearch, completion: { photoDetail, error in
            if let error = error {
                NSLog("\(error)")
                // alert user and dismiss page
            }

            guard let photoDetail = photoDetail else { return }
            DispatchQueue.main.async {
                self.photoDetail = photoDetail
                self.setupViewsWithDetailData(photoDetail: photoDetail)
                self.fetchPhotoComments()
            }
        })
    }

    private func fetchPhotoComments() {
        let urlString = api.createFetchCommentsUrlString(id: tagSearch!.id)
        api.fetchPhotoComments(id: urlString) { photoComments, error in
            if let error = error {
                NSLog("\(error)")
            }

            guard let photoComments = photoComments else { return }
            DispatchQueue.main.async {
                self.photoComments = photoComments
                print("photos counts: ", photoComments.count)
                self.tableView.reloadData()
            }
        }
    }

    private func setupViewsWithDetailData(photoDetail: PhotoDetail) {
        let owner_name = photoDetail.owner_userName.isEmpty ? "Anonymous" : photoDetail.realname
        let descriptionText = "\(photoDetail.title_content)\n\n" + (photoDetail.description_content.isEmpty ? "No Description" : photoDetail.description_content)

        metaDataDictionary = [
            ("owner user name: ",  owner_name),
            ("owner real name:", (photoDetail.realname.isEmpty ? "Anonymous" : photoDetail.realname)),
            ("title:", (photoDetail.title_content.isEmpty ? "No Title" : photoDetail.title_content)),
            ("description:", descriptionText),
            ("views:", photoDetail.views),
            ("taken:", photoDetail.taken),
            ("posted:", photoDetail.posted),
            ("last updated:", photoDetail.lastupdate),
            ("is favorite:", photoDetail.isFavorite == 0 ? "No" : "Yes" ),
            ("is public:", photoDetail.ispublic == 0 ? "No" : "Yes" ),
            ("can blog:", photoDetail.canblog == 0 ? "No" : "Yes"),
            ("can print:", photoDetail.canprint == 0 ? "No" : "Yes" ),
            ("can Share:", photoDetail.canshare == 0 ? "No" : "Yes" ),
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
        if segmentedControl.selectedSegmentIndex == 0 {
            return section == 0 ? metaDataDictionary.count :  (photoDetail?.tags.count ?? 0)
        }
        return photoComments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MetaCell", for: indexPath) as? SubTitleTableViewCell else { return UITableViewCell() }

        if segmentedControl.selectedSegmentIndex == 0 {
            if indexPath.section == 1 {
                cell.textLabel?.text = ""
                cell.detailTextLabel?.text = photoDetail?.tags[indexPath.row]
            } else if indexPath.section == 0 {
                cell.textLabel?.text = metaDataDictionary[indexPath.row].0
                cell.detailTextLabel?.text = metaDataDictionary[indexPath.row].1
                cell.detailTextLabel?.textAlignment = .left
            }
        } else {
            cell.textLabel?.text = photoComments[indexPath.row].authorName
            cell.detailTextLabel?.text = photoComments[indexPath.row].content
        }

        cell.backgroundColor = UIColor().flickr_logoColor()
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .black
        cell.detailTextLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if segmentedControl.selectedSegmentIndex == 0 {
            return section == 0 ? "META" : "TAGS"
        }

        return "\(photoComments.count) Comments"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return 2
        }
        return 1
    }
}
