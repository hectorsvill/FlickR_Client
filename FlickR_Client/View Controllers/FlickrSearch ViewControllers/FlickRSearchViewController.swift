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
//    var sizes: [CGFloat] = []
    typealias collectionDataSource = UICollectionViewDiffableDataSource<Int, TagSearch>
    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource: collectionDataSource! = nil

    let activityIndicator = UIActivityIndicatorView()
    let api = FlickR_API()
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

        if let _ = api.oauthSwift {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .done, target: self, action: #selector(self.logOutButtonPressed))
        }
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
        let search = "Baker Skateboards"
        searchBar.text = search
        searchTag(with: search)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log In", style: .done, target: self, action: #selector(doOAuthFlickr))
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

// MARK: UICollectionViewDelegate
extension FlickRSearchViewController: UICollectionViewDelegate {
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

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        fetchPhotoOperations[indexPath.row]?.cancel()
    }

    func setupCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor().flickr_logoColor()

        //        if let layout = collectionView.collectionViewLayout as? PinterestLayout {
        //            layout.delegate = self
        //        }

        dataSource = UICollectionViewDiffableDataSource<Int, TagSearch>(collectionView: collectionView) {
            [weak self] collectionView, indexPath, tagSearch -> UICollectionViewCell? in

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? TagSearchImageCollectionViewCell else { return UICollectionViewCell() }

            cell.imageView.image = UIImage()
            self?.loadImage(cell: cell, indexPath: indexPath)

            return cell
        }
    }
}

extension FlickRSearchViewController {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.4))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)

        let spacing = CGFloat(8)

        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return  layout
    }

    func configureDataSource(with results: [TagSearch]) {
        var snapShot = NSDiffableDataSourceSnapshot<Int, TagSearch>()
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log In", style: .done, target: self, action: #selector(doOAuthFlickr))
    }
}



//extension FlickRSearchViewController: PinterestLayoutDelegate  {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
//
//        return CGSize(width: itemSize, height: itemSize)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
////        guard let cell = collectionView.cellForItem(at: indexPath) as? TagSearchImageCollectionViewCell else { return CGFloat(40)}
//
//
////        print(cell.imageView.image?.size.height)
//        return sizes[indexPath.item]
//    }
//}

