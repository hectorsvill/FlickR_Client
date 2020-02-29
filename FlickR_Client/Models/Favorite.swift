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
    let farm: Int;
    let id: String;
    let isfamily: Int
    let isfriend: Int
    let ispublic: Int
    let owner: String
    let secret: String
    let server: String
    let title: String;

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
