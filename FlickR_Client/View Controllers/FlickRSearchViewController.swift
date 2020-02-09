//
//  FlickRSearchViewController.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit

final class FlickRSearchViewController: UIViewController {
    typealias collectionDataSource = UICollectionViewDiffableDataSource<Int, TagSearch>
    let activityIndicator = UIActivityIndicatorView()
    let api = FlickR_API()
    var cache = Cache<Int, Data>()
    private let photoFetchQueue = OperationQueue()
    var fetchPhotoOperations: [Int: FetchPhotoOperation] = [:]
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource: collectionDataSource! = nil
    var currentPage = 1
    var currentTagSearch = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        view.addSubview(activityIndicator)
        photoFetchQueue.name = "com.hectorstevenvillasano.andIQuote.FlickR-Client"
        searchTextField.delegate = self
        setupCollectionView()
    }
}

extension FlickRSearchViewController: UICollectionViewDelegate {
    func setupCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        dataSource = UICollectionViewDiffableDataSource<Int, TagSearch>(collectionView: collectionView) { collectionView, indexPath, tagSearch -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? TagSearchImageCollectionViewCell else { return UICollectionViewCell() }
            self.loadImage(cell: cell, indexPath: indexPath)
            return cell
        }
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.25))
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

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchTextField.resignFirstResponder()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tagSearch = dataSource.snapshot().itemIdentifiers[indexPath.item]
        let photoDetailView = PhotoDetailViewController()
        photoDetailView.tagSearch = tagSearch
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
            self.configureDataSource(with: tagSearch)
        }
    }

    func searchTag(with text: String) {
        guard !text.isEmpty else { return }

        activityIndicator.startAnimating()

        let newText = text.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "+")
        api.fetchTagSearch(with: newText) { tagSearch, error in
            if let error = error {
                NSLog("\(error)")
            }

            DispatchQueue.main.async {
                guard let tagSearch = tagSearch else { return }
                self.cache = Cache<Int, Data>()
                self.fetchPhotoOperations = [:]
                self.currentTagSearch = newText
                self.title = "#" + text.trimmingCharacters(in: .whitespaces)
                self.searchTextField.text = nil
                self.activityIndicator.stopAnimating()
                self.setupCollectionView()
                self.configureDataSource(with: tagSearch)
            }
        }
    }

    @IBAction func searchButtonPressed(_ sender: Any) {
        if let text = searchTextField.text {
            searchTag(with: text)
        }

        searchTextField.resignFirstResponder()
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

extension FlickRSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTag(with: textField.text!)
        textField.resignFirstResponder()
        return false
    }
}

