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
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    typealias collectionDataSource = UICollectionViewDiffableDataSource

    override func viewDidLoad() {
        super.viewDidLoad()
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
                self.title = "#" + text.trimmingCharacters(in: .whitespaces)
                self.searchTextField.text = nil
                self.collectionView.reloadData()
            }
            print("page 1 has a total of \(tagSearch.count) images")
        }
    }

    func setupImage(cell: TagSearchImageCollectionViewCell, index: Int) {
        if let data = cache.value(for: index), let image = UIImage(data: data) {
            cell.imageView.image = image
            print("found  cache")
        }else {
            FlickR_API().fetchImage(with: cell.tagSearch!) { data, error in
                if let error = error {
                    NSLog("\(error)")
                }

                guard let data = data else { return }
                self.cache.cache(value: data, for: index)
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        print(data)
                        cell.imageView.image = image
                    }
                }
            }
        }

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
        setupImage(cell: cell, index: indexPath.item)

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
