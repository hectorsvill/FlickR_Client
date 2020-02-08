//
//  FetchPhotoOperation.swift
//  FlickR_Client
//
//  Created by s on 2/8/20.
//  Copyright © 2020 s. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    let flickrImageURL: String
    var imageData: Data?
    private var task: URLSessionDataTask?

    init(urlString: String) {
        self.flickrImageURL = urlString
    }

    override func cancel() {
        task?.cancel()
    }

    override func start() {
        state = .isExecuting
        guard let url = URL(string: flickrImageURL) else { return }

        task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                NSLog("Fectch Operation error: \(error)")
            }

            guard let data = data else { return }
            self.imageData = data
            do {
                self.state = .isFinished
            }
        }

        task?.resume()
    }
}
