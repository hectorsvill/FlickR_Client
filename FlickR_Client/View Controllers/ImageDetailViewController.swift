//
//  ImageDetailViewController.swift
//  FlickR_Client
//
//  Created by s on 2/20/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController, UIViewControllerTransitioningDelegate {

    var image: UIImage?

    var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    var exitButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "arrowshape.turn.up.left")
        button.setImage(image, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor().flickr_logoColor()
        setupView()
    }

    @objc func exitButtonPressed() {

        dismiss(animated: true)
    }
}

extension ImageDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

extension ImageDetailViewController {
    private func setupView() {
        guard let image = image else { return }
        imageView.image = image

        view.addSubview(scrollView)
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self
        view.addSubview(exitButton)
        exitButton.addTarget(self, action: #selector(exitButtonPressed), for: .touchUpInside)

        scrollView.addSubview(imageView)

        NSLayoutConstraint.activate([
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            exitButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            exitButton.heightAnchor.constraint(equalToConstant: 50),


            scrollView.topAnchor.constraint(equalTo: exitButton.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),

        ])

    }
}

