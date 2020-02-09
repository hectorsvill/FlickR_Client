//
//  PhotoDetailViewController.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit

final class PhotoDetailViewController: UIViewController {
    var tagSearch: TagSearch? {
        didSet { setupViews () }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray4
    }

    func setupViews() {
        guard let tagsearch = tagSearch else { return }
        title = tagsearch.title
    }
}
