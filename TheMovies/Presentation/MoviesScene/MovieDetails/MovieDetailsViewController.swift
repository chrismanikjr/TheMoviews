//
//  MovieDetailsViewController.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/22/21.
//

import UIKit

final class MovieDetailsViewController: UIViewController {

    private var stackView: UIStackView!

    private var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x: 0, y: 0, width: 70, height: 200)
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private var overviewTextView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        textView.font = UIFont.preferredFont(forTextStyle: .headline)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        stackView.addArrangedSubview(posterImageView)
        stackView.addArrangedSubview(overviewTextView)
        setupViews()
        bind(to: viewModel)
    }
    

    private var viewModel: MovieDetailsViewModel!
    
    static func create(with viewModel: MovieDetailsViewModel) -> MovieDetailsViewController {
        let view = MovieDetailsViewController()
        view.viewModel = viewModel
        return view
    }
    

    private func bind(to viewModel: MovieDetailsViewModel) {
        viewModel.posterImage.observe(on: self) { [weak self] in self?.posterImageView.image = $0.flatMap(UIImage.init) }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.updatePosterImage(width: Int(posterImageView.imageSizeAfterAspectFit.scaledSize.width))
    }

    // MARK: - Private

    private func setupViews() {
        
        title = viewModel.title
        overviewTextView.text = viewModel.overview
        posterImageView.isHidden = viewModel.isPosterImageHidden
        view.accessibilityIdentifier = AccessibilityIdentifier.movieDetailsView
    }
    
}
