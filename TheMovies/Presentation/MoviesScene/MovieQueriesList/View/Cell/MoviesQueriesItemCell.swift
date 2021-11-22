//
//  MoviesQueriesItemCell.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/21/21.
//

import UIKit

class MoviesQueriesItemCell: UITableViewCell {

    static let height = CGFloat(50)
    static let reuseIdentifier = String(describing: MoviesQueriesItemCell.self)
    
    private var titleLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 2
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    func fill(with suggestion: MoviesQueryListItemViewModel) {
        addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        self.titleLabel.text = suggestion.query
    }

}
