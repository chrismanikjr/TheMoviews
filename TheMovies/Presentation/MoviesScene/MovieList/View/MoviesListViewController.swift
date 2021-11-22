//
//  ViewController.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/18/21.
//

import UIKit

class MoviesListViewController: UIViewController, Alertable {
    
    private var contentView: UIView = {
        let cView = UIView()
        cView.translatesAutoresizingMaskIntoConstraints = false
        cView.backgroundColor = .systemBackground
        
        return cView
    }()
    private var moviesListContainer: UIView = {
        let mView = UIView()
        mView.translatesAutoresizingMaskIntoConstraints = false
        mView.backgroundColor = .systemBackground
        return mView
    }()
    private(set) var suggestionsListContainer: UIView! = {
        let cView = UIView()
        cView.translatesAutoresizingMaskIntoConstraints = false
        cView.backgroundColor = .systemBackground
        return  cView
    }()
    
    private var searchBarContainer: UIView = {
        let sView = UIView()
        sView.translatesAutoresizingMaskIntoConstraints = false
        sView.backgroundColor = .systemBackground
        
        return sView
    }()
    private var emptyDataLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 2
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var searchController = UISearchController(searchResultsController: nil)
    
    private var viewModel: MoviesListViewModel!
    private var posterImagesRepository: PosterImagesRepository?
    
    private var moviesTableViewController: MoviesListTableViewController?
    
    // MARK: - Lifecycle
    
    static func create(with viewModel: MoviesListViewModel,
                       posterImagesRepository: PosterImagesRepository?) -> MoviesListViewController {
        let view = MoviesListViewController()
        view.viewModel = viewModel
        view.posterImagesRepository = posterImagesRepository
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }
    
    
    private func bind(to viewModel: MoviesListViewModel) {
        viewModel.items.observe(on: self) { [weak self] _ in self?.updateItems() }
        viewModel.loading.observe(on: self) { [weak self] in self?.updateLoading($0) }
        viewModel.query.observe(on: self) { [weak self] in self?.updateSearchQuery($0) }
        viewModel.error.observe(on: self) { [weak self] in self?.showError($0) }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.isActive = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: MoviesListTableViewController.self),
            let destinationVC = segue.destination as? MoviesListTableViewController {
            moviesTableViewController = destinationVC
            moviesTableViewController?.viewModel = viewModel
            moviesTableViewController?.posterImagesRepository = posterImagesRepository
        }
    }
    
    // MARK: - Private
    
    private func setupViews() {
        view.addSubview(contentView)
        contentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        contentView.addSubview(searchBarContainer)
        contentView.addSubview(moviesListContainer)
        contentView.addSubview(suggestionsListContainer)
        contentView.addSubview(emptyDataLabel)
        
        searchBarContainer.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        searchBarContainer.heightAnchor.constraint(equalToConstant: 56).isActive = true
        searchBarContainer.bottomAnchor.constraint(equalTo: moviesListContainer.topAnchor).isActive = true
        searchBarContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        searchBarContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        moviesListContainer.topAnchor.constraint(equalTo: searchBarContainer.topAnchor).isActive = true
        moviesListContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        moviesListContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        moviesListContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        searchBarContainer.addSubview(searchController.searchBar)
        
        suggestionsListContainer.topAnchor.constraint(equalTo: searchBarContainer.topAnchor).isActive = true
        suggestionsListContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        suggestionsListContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        suggestionsListContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        emptyDataLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        emptyDataLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        emptyDataLabel.text =  NSLocalizedString("Search results", comment: "")
        
        title = viewModel.screenTitle
        emptyDataLabel.text = viewModel.emptyDataTitle
                setupSearchController()
    }
    
    
    private func updateItems() {
        moviesTableViewController?.reload()
    }

    private func updateLoading(_ loading: MoviesListViewModelLoading?) {
        emptyDataLabel.isHidden = true
        moviesListContainer.isHidden = true
        suggestionsListContainer.isHidden = true
        LoadingView.hide()

        switch loading {
        case .fullScreen: LoadingView.show()
        case .nextPage: moviesListContainer.isHidden = false
        case .none:
            moviesListContainer.isHidden = viewModel.isEmpty
            emptyDataLabel.isHidden = !viewModel.isEmpty
        }

        moviesTableViewController?.updateLoading(loading)
        updateQueriesSuggestions()
    }

    private func updateQueriesSuggestions() {
        guard searchController.searchBar.isFirstResponder else {
            viewModel.closeQueriesSuggestions()
            return
        }
        viewModel.showQueriesSuggestions()
    }

    private func updateSearchQuery(_ query: String) {
        searchController.isActive = false
        searchController.searchBar.text = query
    }

    private func showError(_ error: String) {
        guard !error.isEmpty else { return }
        showAlert(title: viewModel.errorTitle, message: error)
    }
}

// MARK: - Search Controller

extension MoviesListViewController {
    private func setupSearchController() {
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = viewModel.searchBarPlaceholder
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = true
        searchController.searchBar.barStyle = .black
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.frame = searchBarContainer.bounds
        searchController.searchBar.autoresizingMask = [.flexibleWidth]

        definesPresentationContext = true
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.accessibilityIdentifier = AccessibilityIdentifier.searchField
        }
    }
}

extension MoviesListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchController.isActive = false
        viewModel.didSearch(query: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.didCancelSearch()
    }
}

extension MoviesListViewController: UISearchControllerDelegate {
    public func willPresentSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestions()
    }

    public func willDismissSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestions()
    }

    public func didDismissSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestions()
    }
}

