//
//  TagSearch.swift
//  FlickR_Client
//
//  Created by s on 2/7/20.
//  Copyright © 2020 s. All rights reserved.
//

import Foundation

class TagSearch {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int

    init(id: String, owner: String, secret: String, server: String, farm: Int, title: String, ispublic: Int, isfriend: Int, isfamily: Int) {
        self.id = id
        self.owner = owner
        self.secret = secret
        self.server = server
        self.farm = farm
        self.title = title
        self.ispublic = ispublic
        self.isfriend = isfriend
        self.isfamily = isfamily
    }

    convenience init (data: NSDictionary) {
        let id = data["id"] as! String
        let owner = data["owner"] as! String
        let secret = data["secret"] as! String
        let server = data["server"] as! String
        let farm = data["farm"] as! Int
        let title = data["title"] as! String
        let ispublic = data["ispublic"] as! Int
        let isfriend = data["isfriend"] as! Int
        let isfamily = data["isfamily"] as! Int
        self.init(id: id, owner: owner, secret: secret, server: server, farm: farm, title: title, ispublic: ispublic, isfriend: isfriend, isfamily: isfamily)
    }
    
}
