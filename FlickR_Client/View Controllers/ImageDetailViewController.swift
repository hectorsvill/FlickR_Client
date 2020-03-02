//
//  PhotoDetailViewController.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit
import OAuthSwift


final class ImageDetailViewController: UIViewController {
    var api: FlickRAPI!
    var searchContent: SearchContent?
    let activityIndicator = UIActivityIndicatorView()
    var photoDetail: PhotoDetail?
    let tableView = UITableView()
    var metaDataDictionary: [(String, String)] = []
    var photoComments: [PhotoComment] = []

    var centerY: CGFloat!

    let transition = PopAnimator()

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
        configureNavigationButtons()
    }

    private func configureNavigationButtons() {
        guard let searchContent = searchContent else { return }
        let imageName = api.isInFavorites(searchContent: searchContent) ? "hand.thumbsup" : "hand.thumbsup.fill"
        let thumbsupImage = UIImage(systemName: imageName)
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

//        centerY = photoImageView.center.y
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        centerY = photoImageView.center.y
        setupViews()
    }

//    @objc func imageTapped() {
//        UIView.animate(withDuration: 0.3, delay: 0,  options: [.curveEaseOut], animations: {
//            self.photoImageView.center.y =  self.view.center.y
//            self.tableView.isHidden = true
//            self.segmentedControl.isHidden = true
//        }) { _ in
//            let viewController = ImageZoomViewController()
//            viewController.image = self.photoImageView.image
//            viewController.modalPresentationStyle = .fullScreen
//            self.navigationController?.pushViewController(viewController, animated: false)
//            self.photoImageView.center.y += self.centerY
//            self.tableView.isHidden = false
//            self.segmentedControl.isHidden = false
//        }
//    }
}

extension ImageDetailViewController {
    func setupViews() {
        view.backgroundColor = UIColor().flickr_logoColor()
        tableView.translatesAutoresizingMaskIntoConstraints = false

//        view.addSubview(photoImageView)
        view.addSubview(tableView)
        view.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
//            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            photoImageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
//            photoImageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
//            photoImageView.heightAnchor.constraint(equalToConstant: 325),
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            segmentedControl.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    @objc func likeButtonPressed() {
        guard let _ = api.oauthSwift, let tagSearch = searchContent else {
            self.doOAuthFlickr()
            return
        }

        api.oauthSwift?.client.request(api.serviceFavoiritesAddURL, method: .POST, parameters: ["photo_id":"\(tagSearch.id)", "format": "json"], headers: [:], body: nil, checkTokenExpiration: true, completionHandler: { result in
            switch result {
            case .success(let response):
                let dataString = response.dataString(encoding: .utf8)!
                var alertTitle = "ERROR: please try again"

                if dataString.contains("ok") {
                    alertTitle = "adding image to favorites"
                    let favorite = Favorite(date_faved: "", farm: tagSearch.farm, id: tagSearch.id, isfamily: tagSearch.isfamily, isfriend: tagSearch.isfriend, ispublic: tagSearch.ispublic, owner: tagSearch.owner, secret: tagSearch.secret, server: tagSearch.server, title: tagSearch.title)
                    self.api.favorites.append(favorite)
                } else if dataString.contains("Photo is already in favorites") {
                    alertTitle = "Photo is already in favorites"
                }

                let alertController = UIAlertController(title: alertTitle, message: "", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alertController, animated: true) { 
                    self.configureNavigationButtons()
                }

            case .failure(let error):
                print(error)
            }
        })
    }

    @objc func segmentControlDidChange() {
        tableView.reloadData()
    }

    private func fetchImage() {
        guard let tagSearch = searchContent else { return }

        api.fetchImage(with: tagSearch, size: "z") { data, error in
            if let error = error {
                NSLog("\(error)")
            }

            guard let data = data else { return }
            let image = UIImage(data: data)!

            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
    }

    private func fetchPhotoDetail() {
        guard let tagSearch = searchContent else { return }
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
        let urlString = api.createFetchCommentsUrlString(id: searchContent!.id)
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
extension ImageDetailViewController: UITableViewDataSource {
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
        guard let _ = api.oauthSwift else {
            self.doOAuthFlickr()
            return
        }

        let commentViewController = CommentViewController()
        commentViewController.api = api
        commentViewController.photoID = searchContent!.id
        commentViewController.deleagate = self
        present(commentViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if segmentedControl.selectedSegmentIndex == 0 {
            return section == 0 ? "META" : "TAGS"
        }

        return  section == 0 ? "" : "\(photoComments.count) Comment"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return 2
        }
        return 2
    }
}

extension ImageDetailViewController: AddCommentDelegate {
    func addComment(comment: PhotoComment) {
        photoComments.insert(comment, at: 0)
        tableView.reloadData()
    }
}

extension ImageDetailViewController {
    @objc func doOAuthFlickr(){
        let oauthswift = OAuth1Swift(
            consumerKey: api.myKey,
            consumerSecret: api.mySecret,
            requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
            authorizeUrl:    "https://www.flickr.com/services/oauth/authorize",
            accessTokenUrl:  "https://www.flickr.com/services/oauth/access_token"
        )

        self.api.oauthSwift = oauthswift

        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: self.api.oauthSwift!)

        let _ = oauthswift.authorize(withCallbackURL: URL(string: "oauth-swift://oauth-callback/flickr")!) { result in
            switch result {
            case .success(let (_, _, parameters)):
                self.api.userName = parameters["username"] as! String
            case .failure(let error):
                print(error.description)
            }
        }
    }
}
