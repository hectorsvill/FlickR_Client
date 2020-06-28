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

    var noLogInButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let attributedString = NSMutableAttributedString(string: "Login later", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.systemGray3, NSAttributedString.Key.underlineStyle: 1])
        button.setAttributedTitle(NSAttributedString(attributedString: attributedString), for: .normal)
        
        button.addTarget(self, action: #selector(noLoginButtonPressed), for: .touchUpInside)
        
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
        
        
        let stackView = UIStackView(arrangedSubviews: [logoImageView, flickrLogInButton, noLogInButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical

        [stackView, activityIndicator].forEach { view.addSubview($0) }

        let inset: CGFloat = 32
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
//
//            flickrLogInButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: inset),
//            flickrLogInButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -inset),
//            flickrLogInButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 150)
        ])
    }

    @objc func noLoginButtonPressed() {
        dismiss(animated: true, completion: nil)
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
