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

class CommentViewController: UIViewController {
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

    @objc func cancelButtonPressed() {
        dismiss(animated: true)
    }

    @objc func addcommentButtonPressed() {
        guard !commentTextView.text.isEmpty,
            let text = commentTextView.text,
            let url = URL(string: api.createAddCommentsUrl(photoID: photoID!, commentText: text)) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                NSLog("\(error)")
            }
            guard let data = data else { return }
            let resultDict = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
            DispatchQueue.main.async {

                if let stat = resultDict["stat"] as? String, let message = resultDict["message"] as? String {

                    if stat == "ok" {

                        //send commnet to detail view
                        let comment = PhotoComment(id: self.photoID!, authorName: self.api.userName, content: text)
                        self.deleagate?.addComment(comment: comment)

                        let alertController = UIAlertController(title: "Comment added!", message: "", preferredStyle: .alert)

                        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                            self.dismiss(animated: true, completion: nil)
                        })
                        
                        self.present(alertController, animated: true)

                    } else {
                        let alertController = UIAlertController(title: "Error adding comment", message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))

                        self.present(alertController, animated: true)
                    }
                }
            }

        }.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextView.becomeFirstResponder()
        setupView()
    }

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
}


