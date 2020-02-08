//
//  FlickRSearchViewController.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit

class FlickRSearchViewController: UIViewController {
    let api = FlickR_API()

    var cache = Cache<Int, Data>()
    private let photoFetchQueue = OperationQueue()
    var fetchPhotoOperations: [Int: FetchPhotoOperation] = [:]

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    typealias collectionDataSource = UICollectionViewDiffableDataSource

    override func viewDidLoad() {
        super.viewDidLoad()

        photoFetchQueue.name = "com.hectorstevenvillasano.andIQuote.FlickR-Client"
        searchTextField.delegate = self
//        collectionView.collectionViewLayout =
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        if let text = searchTextField.text {
            searchTag(with: text)
        }

        searchTextField.resignFirstResponder()
    }

    func searchTag(with text: String) {
        guard !text.isEmpty else { return }

        let newText = text.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "+")

        api.fetchTagSearch(with: newText) { tagSearch, error in
            if let error = error {
                NSLog("\(error)")
            }

            guard let tagSearch = tagSearch else { return }
            DispatchQueue.main.async {
                self.cache = Cache<Int, Data>()
                self.fetchPhotoOperations = [:]
                self.title = "#" + text.trimmingCharacters(in: .whitespaces)
                self.searchTextField.text = nil
                self.collectionView.reloadData()
            }
            print("page 1 has a total of \(tagSearch.count) images")
        }
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

extension FlickRSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return api.tagSearch.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? TagSearchImageCollectionViewCell else { return UICollectionViewCell() }

        let tagSearch = api.tagSearch[indexPath.item]
        cell.tagSearch = tagSearch
        loadImage(cell: cell, indexPath: indexPath)

        return cell
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


extension FlickRSearchViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//         return CGSize(width: view.frame.width / 4, height: view.frame.height / 4)
//    }
}
