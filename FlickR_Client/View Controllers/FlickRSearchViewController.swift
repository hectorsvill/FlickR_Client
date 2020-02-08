//
//  FlickRSearchViewController.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit

class FlickRSearchViewController: UIViewController {
    typealias collectionDataSource = UICollectionViewDiffableDataSource<Int, TagSearch>

    let api = FlickR_API()
    var cache = Cache<Int, Data>()
    private let photoFetchQueue = OperationQueue()
    var fetchPhotoOperations: [Int: FetchPhotoOperation] = [:]
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource: collectionDataSource! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

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
            cell.tagSearch = tagSearch
            self.loadImage(cell: cell, indexPath: indexPath)
            return cell
        }
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

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
        snapShot.appendItems(results)
        dataSource.apply(snapShot, animatingDifferences: true)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchTextField.resignFirstResponder()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        let tagSearch = api.tagSearch[index]
        let photoDetailView = PhotoDetailViewController()
        photoDetailView.tagSearch = tagSearch
        navigationController?.pushViewController(photoDetailView, animated: true)
    }
}


extension FlickRSearchViewController {
    func searchTag(with text: String) {
        guard !text.isEmpty else { return }
        
        let newText = text.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "+")

        api.fetchTagSearch(with: newText) { tagSearch, error in
            if let error = error {
                NSLog("\(error)")
            }

            DispatchQueue.main.async {
                guard let tagSearch = tagSearch else { return }
                self.cache = Cache<Int, Data>()
                self.fetchPhotoOperations = [:]
                self.title = "#" + text.trimmingCharacters(in: .whitespaces)
                self.searchTextField.text = nil
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
        
        let tagSearch = api.tagSearch[indexPath.item]
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
        fetchPhotoOperations[indexPath.row]?.cancel()
    }
}

extension FlickRSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTag(with: textField.text!)
        textField.resignFirstResponder()
        return false
    }

}

