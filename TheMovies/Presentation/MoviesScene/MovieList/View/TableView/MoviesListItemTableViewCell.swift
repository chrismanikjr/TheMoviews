//
//  MoviesListItemTableViewCell.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/19/21.
//

import UIKit

final class MoviesListItemTableViewCell: UITableViewCell {

    static let reuseIdentifier = String(describing: MoviesListItemTableViewCell.self)
    static let height = CGFloat(120)
    private var stackView: UIStackView!
    private var titleLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Title"
        label.numberOfLines = 2
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Release Date"
        label.numberOfLines = 2
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var overviewLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Overview"
        label.numberOfLines = 20
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x: 0, y: 0, width: 70, height: 100)
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var viewModel: MoviesListItemViewModel!
    private var posterImagesRepository: PosterImagesRepository?
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }

    func fill(with viewModel: MoviesListItemViewModel, posterImagesRepository: PosterImagesRepository?) {
        self.viewModel = viewModel
        self.posterImagesRepository = posterImagesRepository
        addSubview(stackView)
        addSubview(posterImageView)
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 8).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
        stackView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: 10).isActive = true
        stackView.axis = .vertical
        
        posterImageView.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
        posterImageView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: 10).isActive = true
        posterImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(overviewLabel)
        
        titleLabel.text = viewModel.title
        dateLabel.text = viewModel.releaseDate
        overviewLabel.text = viewModel.overview
        updatePosterImage(width: Int(posterImageView.imageSizeAfterAspectFit.scaledSize.width))
    }

    private func updatePosterImage(width: Int) {
        posterImageView.image = nil
        guard let posterImagePath = viewModel.posterImagePath else { return }

        imageLoadTask = posterImagesRepository?.fetchImage(with: posterImagePath, width: width) { [weak self] result in
            guard let self = self else { return }
            guard self.viewModel.posterImagePath == posterImagePath else { return }
            if case let .success(data) = result {
                self.posterImageView.image = UIImage(data: data)
            }
            self.imageLoadTask = nil
        }
    }

}
