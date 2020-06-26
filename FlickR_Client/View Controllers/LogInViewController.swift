//
//  LogInViewController.swift
//  FlickR_Client
//
//  Created by s on 2/29/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit
import OAuthSwift

class LogInViewController: UIViewController {
    let activityIndicator = UIActivityIndicatorView()
    var api: FlickRAPI?

    var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "flickR_logo")
        imageView.backgroundColor = UIColor().flickr_logoColor()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    var flickrLogInButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        button.tintColor = .white
        button.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        button.layer.cornerRadius = 13
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor().flickr_logoColor()
        setupViews()
    }

    private func setupViews() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.color = .black

        [logoImageView, flickrLogInButton, activityIndicator].forEach { view.addSubview($0) }

        let inset: CGFloat = 32
        
        NSLayoutConstraint.activate([
            logoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logoImageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            logoImageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),

            flickrLogInButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: inset),
            flickrLogInButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -inset),
            flickrLogInButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 150)
        ])
    }

    @objc func loginButtonPressed() {
        guard let api = api else { return }
        activityIndicator.startAnimating()

           let oauthswift = OAuth1Swift(
               consumerKey: api.myKey,
               consumerSecret: api.mySecret,
               requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
               authorizeUrl:    "https://www.flickr.com/services/oauth/authorize",
               accessTokenUrl:  "https://www.flickr.com/services/oauth/access_token"
           )

           api.oauthSwift = oauthswift
           oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: api.oauthSwift!)

           let _ = oauthswift.authorize(withCallbackURL: URL(string: "oauth-swift://oauth-callback/flickr")!) { result in
               switch result {
               case .success(let (_, _, parameters)):
                   api.userName = parameters["username"] as! String
                   self.dismiss(animated: true)
               case .failure(let error):
                   print(error.description)
               }
           }
        self.activityIndicator.stopAnimating()
       }
}
