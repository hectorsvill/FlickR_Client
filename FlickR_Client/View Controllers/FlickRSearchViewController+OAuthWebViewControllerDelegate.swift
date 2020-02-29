//
//  FlickRSearchViewController+OAuthWebViewControllerDelegate.swift
//  FlickR_Client
//
//  Created by s on 2/28/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit
import OAuthSwift

// MARK: OAuthWebViewControllerDelegate
extension FlickRSearchViewController: OAuthWebViewControllerDelegate {
    func oauthWebViewControllerDidPresent() {
    }

    func oauthWebViewControllerDidDismiss() {
    }

    func oauthWebViewControllerWillAppear() {
    }

    func oauthWebViewControllerDidAppear() {
    }

    func oauthWebViewControllerWillDisappear() {
    }

    func oauthWebViewControllerDidDisappear() {
        api.oauthSwift?.cancel()
    }

    @objc func doOAuthFlickr(){
        let oauthswift = OAuth1Swift(
            consumerKey: api.myKey,
            consumerSecret: api.mySecret,
            requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
            authorizeUrl:    "https://www.flickr.com/services/oauth/authorize",
            accessTokenUrl:  "https://www.flickr.com/services/oauth/access_token"
        )

        self.api.oauthSwift = oauthswift

        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: self.api.oauthSwift!)

        let _ = oauthswift.authorize(withCallbackURL: URL(string: "oauth-swift://oauth-callback/flickr")!) { result in
            switch result {
            case .success(let (_, _, parameters)):
                self.api.userName = parameters["username"] as! String
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .done, target: self, action: #selector(self.logOutButtonPressed))
            case .failure(let error):
                print(error.description)
            }
        }
    }

    @objc func logOutButtonPressed() {
        api.oauthSwift = nil
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log In", style: .done, target: self, action: #selector(doOAuthFlickr))
    }
}
