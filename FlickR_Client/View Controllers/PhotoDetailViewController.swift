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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewDidLoad()

        let thumbsupImage = UIImage(systemName: "hand.thumbsup")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: thumbsupImage, style: .plain, target: self, action: #selector(likeButtonPressed))
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
    }
}

extension PhotoDetailViewController {
    func setupViews() {
        view.backgroundColor = UIColor().flickr_logoColor()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photoImageView)
        view.addSubview(tableView)
        view.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoImageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            photoImageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            photoImageView.heightAnchor.constraint(equalToConstant: 325),
            segmentedControl.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 8),
            segmentedControl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            segmentedControl.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    @objc func likeButtonPressed() {
        guard !api.authToken.isEmpty else {
            let alertController = UIAlertController(title: "Auth Error", message: "Please Log In", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true)
            return
        }

        let urlString = api.createFavoriteUrlString(tagSearch: tagSearch!)
        URLSession.shared.dataTask(with: URL(string: urlString)!) { data, _, error in
            if let error = error {
                NSLog("\(error)")
            }

            guard let data = data else { return }
            let resultDict = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
            DispatchQueue.main.async {
                if let stat = resultDict["stat"] as? String, let message = resultDict["message"] as? String {
                    
                    if stat == "ok" {
                        let thumbsupImage = UIImage(systemName: "hand.thumbsup.fill")
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: thumbsupImage, style: .plain, target: self, action: #selector(self.unLikeButtonPressed))
                    } else {
                        let alertController = UIAlertController(title: "Error adding image to favorites", message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))

                        self.present(alertController, animated: true)
                    }
                }
            }
        }.resume()
    }

    @objc func unLikeButtonPressed() {
        let urlString = api.createFavoriteUrlString(action: "remove", tagSearch: tagSearch!)
        print(urlString)

        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                NSLog("\(error)")
            }

            guard let data = data else { return }
            let resultDict = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
            DispatchQueue.main.async {
                if let stat = resultDict["stat"] as? String, let message = resultDict["message"] as? String {

                    if stat == "ok" {
                        let thumbsupImage = UIImage(systemName: "hand.thumbsup")
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: thumbsupImage, style: .plain, target: self, action: #selector(self.likeButtonPressed))
                    } else {
                        let alertController = UIAlertController(title: "Error removing image from favorites", message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))

                        self.present(alertController, animated: true)
                    }
                }
            }
        }.resume()
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
                self.setupTableViewDataSource(photoDetail: photoDetail)
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
                self.tableView.reloadData()
            }
        }
    }

    private func setupTableViewDataSource(photoDetail: PhotoDetail) {
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

        tableView.reloadData()
    }
}
extension PhotoDetailViewController: UITableViewDataSource {
    func setupTagTableView() {
        tableView.dataSource = self
        tableView.register(SubTitleTableViewCell.self, forCellReuseIdentifier: "MetaCell")
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: "CommentCell")
        tableView.backgroundColor = UIColor().flickr_logoColor()
        tableView.allowsSelection = false
        tableView.separatorStyle = .singleLine
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return section == 0 ? metaDataDictionary.count :  (photoDetail?.tags.count ?? 0)
        }

        return section == 0 ? 1 : photoComments.count
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
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
                cell.button.addTarget(self, action: #selector(commentButtonPressed), for: .touchUpInside)
                return cell
            } else {
                cell.textLabel?.text = photoComments[indexPath.row].authorName
                cell.detailTextLabel?.text = photoComments[indexPath.row].content
            }
        }

        cell.backgroundColor = UIColor().flickr_logoColor()
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .black
        cell.detailTextLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)

        return cell
    }

    @objc func commentButtonPressed() {
        guard !api.authToken.isEmpty else {
            let alertController = UIAlertController(title: "Auth Error", message: "Please Log In", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true)
            return
        }

        let commentViewController = CommentViewController()
        commentViewController.api = api
        commentViewController.photoID = tagSearch!.id
        present(commentViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if segmentedControl.selectedSegmentIndex == 0 {
            return section == 0 ? "META" : "TAGS"
        }

        return  section == 0 ? "" : "\(photoComments.count) Comments"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return 2
        }
        return 2
    }
}

extension PhotoDetailViewController: AddCommentDelegate {
    func addComment(comment: PhotoComment) {
        photoComments.insert(comment, at: 0)
        tableView.reloadData()
    }
}
