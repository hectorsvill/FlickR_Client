//
//  PhotoComments.swift
//  FlickR_Client
//
//  Created by s on 2/9/20.
//  Copyright © 2020 s. All rights reserved.
//

import Foundation

struct PhotoComment: Hashable {
    let id: String
    let authorName: String
    let content: String

    init(id: String, authorName: String, content: String) {
        self.id = id
        self.authorName = authorName
        self.content = content
    }

    init(resultDict: [String: AnyObject]) {
        let id = resultDict["id"] as! String
        let authorName = resultDict["authorName"] as! String
        let content = resultDict["Content"] as! String
        self.init(id: id, authorName: authorName, content: content)
    }
}
