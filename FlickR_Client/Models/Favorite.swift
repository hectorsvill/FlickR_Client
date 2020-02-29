//
//  Favorite.swift
//  FlickR_Client
//
//  Created by s on 2/29/20.
//  Copyright © 2020 s. All rights reserved.
//

import Foundation


struct Favorite {
    let date_faved: String
    let farm: Int
    let id: String
    let isfamily: Int
    let isfriend: Int
    let ispublic: Int
    let owner: String
    let secret: String
    let server: String
    let title: String

    init(date_faved: String, farm: Int, id: String, isfamily: Int, isfriend: Int,
         ispublic: Int, owner: String, secret: String, server: String, title: String) {
        self.date_faved = date_faved
        self.farm = farm
        self.id = id
        self.isfamily = isfamily
        self.isfriend = isfriend
        self.ispublic = ispublic
        self.owner = owner
        self.secret = secret
        self.server = server
        self.title = title
    }

    init(data: NSDictionary) {
        self.date_faved = data["date_faved"] as! String
        self.farm = data["farm"] as! Int
        self.id = data["id"] as! String
        self.isfamily = data["isfamily"] as! Int
        self.isfriend = data["isfriend"] as! Int
        self.ispublic = data["ispublic"] as! Int
        self.owner = data["owner"] as! String
        self.secret = data["secret"] as! String
        self.server = data["server"] as! String
        self.title = data["title"] as! String
    }
}
