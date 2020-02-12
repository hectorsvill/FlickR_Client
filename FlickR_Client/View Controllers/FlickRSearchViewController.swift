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
    typealias collectionDataSource = UICollectionViewDiffableDataSource<Int, TagSearch>
    let activityIndicator = UIActivityIndicatorView()
    let api = FlickR_API()
    var cache = Cache<Int, Data>()
    private let photoFetchQueue = OperationQueue()
    var fetchPhotoOperations: [Int: FetchPhotoOperation] = [:]

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var flickrLogoImageView: UIImageView!

    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource: collectionDataSource! = nil
    var currentPage = 1
    var currentTagSearch = ""
    @IBOutlet weak var flickR_logo: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        photoFetchQueue.name = "com.hectorstevenvillasano.andIQuote.FlickR-Client"
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
        searchBar.text = "Mountains"
        searchTag(with: "Mountains")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log In", style: .done, target: self, action: #selector(doOAuthFlickr))
    }

    @IBAction func trashButtonPressed(_ sender: Any) {
        flickrLogoImageView.isHidden = false
        searchBar.text = nil
        searchBar.resignFirstResponder()
        setupCollectionView()
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

extension FlickRSearchViewController: UICollectionViewDelegate {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.34))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)

        let spacing = CGFloat(8)

        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return  layout
    }

    func setupCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor().flickr_logoColor()

        dataSource = UICollectionViewDiffableDataSource<Int, TagSearch>(collectionView: collectionView) { collectionView, indexPath, tagSearch -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? TagSearchImageCollectionViewCell else { return UICollectionViewCell() }
            cell.titleLable.text = tagSearch.title.isEmpty ? "no title" : tagSearch.title
            self.loadImage(cell: cell, indexPath: indexPath)
            return cell
        }
    }

    func configureDataSource(with results: [TagSearch]) {
        var snapShot = NSDiffableDataSourceSnapshot<Int, TagSearch>()
        snapShot.appendSections([0])
        snapShot.appendItems(dataSource.snapshot().itemIdentifiers)
        snapShot.appendItems(results)
        dataSource.apply(snapShot, animatingDifferences: false)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tagSearch = dataSource.snapshot().itemIdentifiers[indexPath.item]
        let photoDetailView = PhotoDetailViewController()
        photoDetailView.tagSearch = tagSearch
        photoDetailView.api = api
        navigationController?.pushViewController(photoDetailView, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == dataSource.snapshot().itemIdentifiers.count - 1 {
            currentPage += 1
            self.perform(#selector(fetchNextData), with: nil)
        }
    }
}


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

    func loadImage(cell: TagSearchImageCollectionViewCell, indexPath: IndexPath) {
        if let data = cache.value(for: indexPath.item), let image = UIImage(data: data) {
            cell.imageView.image = image
        }
        
        let tagSearch = dataSource.snapshot().itemIdentifiers[indexPath.item]
        let urlString = api.createPhotoUrlString(with: tagSearch)

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

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        fetchPhotoOperations[indexPath.row]?.cancel()
    }
}

// MARK: OAuthWebViewControllerDelegate
extension FlickRSearchViewController: OAuthWebViewControllerDelegate {
    func oauthWebViewControllerDidPresent() {
    }

    func oauthWebViewControllerDidDismiss() {
    }

    func oauthWebViewControllerWillAppear() {
    }

    func oauthWebViewControllerDidAppear() {
    }

    func oauthWebViewControllerWillDisappear() {
    }

    func oauthWebViewControllerDidDisappear() {
        api.oauthSwift?.cancel()
    }

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
            case .success(let (credential, _, parameters)):
                self.api.authToken = credential.oauthToken
                self.api.authTokenSecret =  credential.oauthTokenSecret
                self.api.userName = parameters["username"] as! String
                print("token: \(credential.oauthToken) \n secret: \(credential.oauthTokenSecret), \(parameters), ")
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .done, target: self, action: #selector(self.logOutButtonPressed))
            case .failure(let error):
                print(error.description)
            }
        }
    }

    @objc func logOutButtonPressed() {
        api.authToken = ""
        api.authTokenSecret = ""
        api.oauthSwift = nil
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log In", style: .done, target: self, action: #selector(doOAuthFlickr))
    }
}
