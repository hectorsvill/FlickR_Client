//
//  PhotoDetail.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import Foundation


class PhotoDetail {
    let isFavorite: Int
    let owner_userName: String
    let realname: String
    let title_content: String
    let description_content: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    let posted: String
    let taken: String
    let lastupdate: String
    let views: String
    let candownload: Int
    let canblog: Int
    let canprint: Int
    let canshare: Int
    let tags: [String]

    init(isFavorite: Int, owner_userName: String, realname: String, title_content: String, description_content: String, ispublic: Int, isfriend: Int, isfamily: Int, posted: String, taken: String, lastupdate: String, views: String,
         candownload: Int, canblog: Int, canprint: Int, canshare: Int, tags: [String]) {
        self.isFavorite = isFavorite
        self.owner_userName = owner_userName
        self.realname = realname
        self.title_content = title_content
        self.description_content = description_content
        self.ispublic = ispublic
        self.isfriend = isfriend
        self.isfamily = isfamily
        self.posted = posted
        self.taken = taken
        self.lastupdate = lastupdate
        self.views = views
        self.candownload = candownload
        self.canblog = canblog
        self.canprint = canprint
        self.canshare = canshare
        self.tags = tags
    }

    convenience init(data: [String: AnyObject]) {
        let photo = data["photo"] as! NSDictionary
        let isFavorite = photo["isfavorite"] as! Int

        let owner = photo["owner"] as! NSDictionary
        let owner_userName = owner["username"] as! String
        let realname = owner["realname"] as! String

        let title = photo["title"] as! NSDictionary
        let title_content = title["_content"] as! String

        let description = photo["description"] as! NSDictionary
        let description_content = description["_content"] as! String

        let visibitlity = photo["visibility"] as! NSDictionary
        let ispublic = visibitlity["ispublic"] as! Int
        let isfriend = visibitlity["isfriend"] as! Int
        let isfamily = visibitlity["isfamily"] as! Int

        let dates = photo["dates"] as! NSDictionary
        let posted = dates["posted"] as! String
        let taken = dates["taken"] as! String
        let lastupdate = dates["lastupdate"] as! String

        let views = photo["views"] as! String

        let usage = photo["usage"] as! NSDictionary
        let candownload = usage["candownload"] as! Int
        let canblog = usage["canblog"] as! Int
        let canprint = usage["canprint"] as! Int
        let canshare = usage["canshare"] as! Int

        let photo_tags = photo["tags"] as! NSDictionary
        let tag_list = photo_tags["tag"] as! [NSDictionary]
        let tags: [String] = tag_list.map {
            let tag = $0["raw"] as! String
            return tag
        }
        self.init(isFavorite: isFavorite, owner_userName: owner_userName, realname: realname, title_content: title_content, description_content: description_content, ispublic: ispublic, isfriend: isfriend, isfamily: isfamily, posted: posted, taken: taken, lastupdate: lastupdate, views: views, candownload: candownload, canblog: canblog, canprint: canprint, canshare: canshare, tags: tags)
    }


}
