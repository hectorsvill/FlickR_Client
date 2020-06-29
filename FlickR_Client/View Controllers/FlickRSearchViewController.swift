//
//  FlickRSearchViewController.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import WebKit
import UIKit
import OAuthSwift

final class FlickRSearchViewController: UIViewController {
    typealias collectionDataSource = UICollectionViewDiffableDataSource<Int, SearchContent>
    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource: collectionDataSource! = nil

    let activityIndicator = UIActivityIndicatorView()
    let api = FlickRAPI()
    var cache = Cache<Int, Data>()
    private let photoFetchQueue = OperationQueue()
    var fetchPhotoOperations: [Int: FetchPhotoOperation] = [:]

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var flickrLogoImageView: UIImageView!

    var currentPage = 1
    var currentTagSearch = ""
    @IBOutlet weak var flickR_logo: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !api.noLoginOptIn {
            navigateToLogIn()
        }
        
        let leftBarButtonTitle = api.noLoginOptIn ? "Login" : "Log out"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: leftBarButtonTitle, style: .done, target: self, action: #selector(self.logOutButtonPressed))
    }

    private func navigateToLogIn() {
        let vc = LogInViewController()
        vc.api = api
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }

    private func setupView() {
        photoFetchQueue.name = "com.hectorstevenvillasano.FlickRClient"
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        activityIndicator.color = .systemBlue
        view.addSubview(activityIndicator)
        setupCollectionView()
        view.backgroundColor = UIColor().flickr_logoColor()
        flickR_logo.backgroundColor = UIColor().flickr_logoColor()
        navigationController?.navigationBar.tintColor = UIColor().flickr_logoColor()
        searchBar.delegate = self
        searchBar.backgroundColor = UIColor().flickr_logoColor()

        // MARK: DELETE
        let search = "Baker Skateboards"
        searchBar.text = search
        searchTag(with: search)

    }

    @IBAction func trashButtonPressed(_ sender: Any) {
        flickrLogoImageView.isHidden = false
        searchBar.text = nil
        searchBar.resignFirstResponder()
        setupCollectionView()
        configureDataSource(with: [])
    }
}

// MARK: UISearchBarDelegate
extension FlickRSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchTag(with: searchBar.text!)
        searchBar.resignFirstResponder()
    }
}

// MARK: UICollectionViewDelegate\\\\
extension FlickRSearchViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }

     func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         if indexPath.item == dataSource.snapshot().itemIdentifiers.count - 1 {
             currentPage += 1
             self.perform(#selector(fetchNextData), with: nil)
         }
     }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        fetchPhotoOperations[indexPath.row]?.cancel()
    }

    func setupCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor().flickr_logoColor()

        dataSource = UICollectionViewDiffableDataSource<Int, SearchContent>(collectionView: collectionView) {
            collectionView, indexPath, searchContent -> UICollectionViewCell? in

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? TagSearchContentCollectionViewCell else { return UICollectionViewCell() }
            cell.searchContent = searchContent
            cell.delegate = self
            cell.isFavorite = self.api.isInFavorites(searchContent: searchContent)
            cell.imageView.image = UIImage()
            
                    
            if (!self.api.noLoginOptIn) {
                let imageName = cell.isFavorite ?  "hand.thumbsup" : "hand.thumbsup.fill"
                let image = UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .large))
                cell.likeButton.setImage(image, for: .normal)
                cell.likeButton.isHidden = true
            }
            
            self.loadImage(cell: cell, indexPath: indexPath)

            return cell
        }
    }

    func navigateToDetailView(_ searchContent: SearchContent) {
        let photoDetailView = ImageDetailViewController()
        photoDetailView.searchContent = searchContent
        photoDetailView.api = api
        navigationController?.pushViewController(photoDetailView, animated: true)
    }

    @objc func navigateToImageZoomView() {
        let viewController = ImageZoomViewController()
//        viewController.image = self.photoImageView.image
        viewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(viewController, animated: false)
    }
}

extension FlickRSearchViewController: TagSearchContentCollectionDelegate {
    func likeButtonPressed(_ searchContent: SearchContent) {

//        let alertController = UIAlertController(title: alertTitle, message: "", preferredStyle: .actionSheet)
//        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
//        self.present(alertController, animated: true)

        api.oauthSwift?.client.request(api.serviceFavoiritesAddURL, method: .POST, parameters: ["photo_id":"\(searchContent.id)", "format": "json"], headers: [:], body: nil, checkTokenExpiration: true, completionHandler: { result in
            switch result {
            case .success(let response):
                let dataString = response.dataString(encoding: .utf8)!
                var alertTitle = "ERROR: please try again"

                if dataString.contains("ok") {
                    alertTitle = "adding image to favorites"
                    let favorite = Favorite(date_faved: "", farm: searchContent.farm, id: searchContent.id, isfamily: searchContent.isfamily, isfriend: searchContent.isfriend, ispublic: searchContent.ispublic, owner: searchContent.owner, secret: searchContent.secret, server: searchContent.server, title: searchContent.title)
                    self.api.favorites.append(favorite)
                } else if dataString.contains("Photo is already in favorites") {
                    alertTitle = "Photo is already in favorites"
                }
                NSLog("\(alertTitle)")
            case .failure(let error):
                print(error)
            }
        })


    }

    func infoButtonPressed(_ searchContent: SearchContent) {
        navigateToDetailView(searchContent)
    }
}

extension FlickRSearchViewController {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.35))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)

        let spacing = CGFloat(8)

        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return  layout
    }

    func configureDataSource(with results: [SearchContent]) {
        var snapShot = NSDiffableDataSourceSnapshot<Int, SearchContent>()
        snapShot.appendSections([0])
        snapShot.appendItems(dataSource.snapshot().itemIdentifiers)
        snapShot.appendItems(results)

        dataSource.apply(snapShot, animatingDifferences: false)
    }
}

// MARK: Networking
extension FlickRSearchViewController {
    @objc func fetchNextData() {
        api.fetchTagSearch(with: currentTagSearch, page: currentPage) { tagSearch, error in
            if let error = error {
                NSLog("\(error)")
            }

            guard let tagSearch = tagSearch else { return }
            DispatchQueue.main.async {
                self.configureDataSource(with: tagSearch)
            }
        }
    }

    func searchTag(with text: String) {
        guard !text.isEmpty else { return }
        activityIndicator.startAnimating()

        let newText = api.textHelper(text)

        api.fetchTagSearch(with: newText) { tagSearch, error in
            if let error = error {
                NSLog("\(error)")
            }

            DispatchQueue.main.async {
                guard let tagSearch = tagSearch else { return }
                self.flickrLogoImageView.isHidden = !tagSearch.isEmpty ? true : false
                self.cache = Cache<Int, Data>()
                self.fetchPhotoOperations = [:]
                self.currentTagSearch = newText
                self.activityIndicator.stopAnimating()
                self.setupCollectionView()
                self.configureDataSource(with: tagSearch)
            }
        }
    }

    func loadImage(cell: TagSearchContentCollectionViewCell, indexPath: IndexPath) {
        if let data = cache.value(for: indexPath.item), let image = UIImage(data: data) {
            cell.imageView.image = image
        }
        
        let tagSearch = dataSource.snapshot().itemIdentifiers[indexPath.item]
        let urlString = api.createPhotoUrlString(with: tagSearch, size: "z")

        let fetchPhotoOperation = FetchPhotoOperation(urlString: urlString)

        let storePhotoInCacheOperation = BlockOperation {
            if let imageData = fetchPhotoOperation.imageData {
                self.cache.cache(value: imageData, for: indexPath.item)
            }
        }

        let checkingForReUsedCell = BlockOperation {
            if self.collectionView.indexPath(for: cell) == indexPath {
                guard let imageData = fetchPhotoOperation.imageData else { return }
                cell.imageView.image = UIImage(data: imageData)
            }
        }

        storePhotoInCacheOperation.addDependency(fetchPhotoOperation)
        checkingForReUsedCell.addDependency(fetchPhotoOperation)

        photoFetchQueue.addOperations([fetchPhotoOperation,storePhotoInCacheOperation], waitUntilFinished: false)
        OperationQueue.main.addOperation(checkingForReUsedCell)
        fetchPhotoOperations[indexPath.item] = fetchPhotoOperation
    }
}

// MARK: OAuthWebViewControllerDelegate
extension FlickRSearchViewController {
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
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .done, target: self, action: #selector(self.logOutButtonPressed))
            case .failure(let error):
                print(error.description)
            }
        }
    }

    @objc func logOutButtonPressed() {
        api.oauthSwift = nil
        api.userName = ""
        trashButtonPressed(UIButton())
        navigateToLogIn()
    }
}


