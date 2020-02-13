//
//  CommentViewController.swift
//  FlickR_Client
//
//  Created by s on 2/11/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit

protocol AddCommentDelegate {
    func addComment(comment: PhotoComment)
}

final class CommentViewController: UIViewController {
    var api: FlickR_API!
    var photoID: String?
    var deleagate: AddCommentDelegate?
    
    var commentTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    var addCommentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 3
        button.backgroundColor = .systemBlue
        button.tintColor = UIColor().flickr_logoColor()
        button.setTitle("Add Comment", for: .normal)
        button.addTarget(self, action: #selector(addcommentButtonPressed), for: .touchUpInside)
        return button
    }()

    var cancelButton: UIButton = {
           let button = UIButton()
           button.translatesAutoresizingMaskIntoConstraints = false
           button.layer.cornerRadius = 3
           button.backgroundColor = .systemRed
           button.tintColor = UIColor().flickr_logoColor()
           button.setTitle("Cancel", for: .normal)
           button.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
           return button
       }()


    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextView.becomeFirstResponder()
        setupView()
    }
}

extension CommentViewController {
    private func setupView() {
        view.backgroundColor = UIColor().flickr_logoColor()
        view.addSubview(commentTextView)
        view.addSubview(addCommentButton)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            commentTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            commentTextView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            commentTextView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            commentTextView.heightAnchor.constraint(equalToConstant: 125),

            addCommentButton.topAnchor.constraint(equalTo: commentTextView.bottomAnchor, constant: 8),
            addCommentButton.leftAnchor.constraint(equalTo: commentTextView.leftAnchor, constant: 16),
            addCommentButton.rightAnchor.constraint(equalTo: commentTextView.rightAnchor, constant: -16),

            cancelButton.topAnchor.constraint(equalTo: addCommentButton.bottomAnchor, constant: 8),
            cancelButton.leftAnchor.constraint(equalTo: addCommentButton.leftAnchor, constant: 16),
            cancelButton.rightAnchor.constraint(equalTo: addCommentButton.rightAnchor, constant: -16),
        ])
    }

    @objc func cancelButtonPressed() {
        dismiss(animated: true)
    }

    @objc func addcommentButtonPressed() {
        guard !commentTextView.text.isEmpty,
            let text = commentTextView.text, let photoID = photoID else { return }
        api.oauthSwift?.client.request(api.serviceAddCommentURL, method: .POST, parameters: ["photo_id":"\(photoID)", "comment_text":text,"format": "json"], headers: [:], body: nil, checkTokenExpiration: true, completionHandler: { result in
            switch result {
            case .success(let response):
                let dataString = response.dataString(encoding: .utf8)!
                var alertTitle = "ERROR: please try again"

                if dataString.contains("ok") {
                    alertTitle = "added comment to photo"
                    self.deleagate?.addComment(comment: PhotoComment(id: photoID, authorName: self.api.userName, content: text))
                }

                let alertController = UIAlertController(title: alertTitle, message: "", preferredStyle: .alert)

                alertController.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
                    self.dismiss(animated: true, completion: nil)
                })

                self.present(alertController, animated: true)
           case .failure(let error):
               print(error)
           }
        })

    }

}


