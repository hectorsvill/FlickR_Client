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
extension UIViewController: OAuthWebViewControllerDelegate {
    public func oauthWebViewControllerDidPresent() {
        print("oauthWebViewControllerDidPresent")
    }

    public func oauthWebViewControllerDidDismiss() {
        print("oauthWebViewControllerDidPresent")
    }

    public func oauthWebViewControllerWillAppear() {
        print("oauthWebViewControllerDidPresent")
    }

    public func oauthWebViewControllerDidAppear() {
        print("oauthWebViewControllerDidPresent")
    }

    public func oauthWebViewControllerWillDisappear() {
        print("oauthWebViewControllerDidPresent")
    }

    public func oauthWebViewControllerDidDisappear() {
        
        print("oauthWebViewControllerDidPresent")
    }
}

