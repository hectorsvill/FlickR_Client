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
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationController?.navigationBar.tintColor = .systemGray2
//        view.backgroundColor = .systemGray2

        searchTextField.delegate = self
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        if let text = searchTextField.text {
            searchTag(with: text)

        } else {

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
            print(tagSearch.count)
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
