//
//  CocktailListViewController.swift
//  ShakeMate
//
//  Created by Mateo Piskac on 10.07.2024..
//

import UIKit
import Combine
import Kingfisher
import PureLayout

class CocktailListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {

    private var tableView: UITableView!
    private var viewModel: CocktailViewModel!
    private var cancellables = Set<AnyCancellable>()
    private var searchController: UISearchController!
    private var searchTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchCocktails()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData() // Reload data to update favorite status
    }

    init(viewModel: CocktailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        title = "Cocktails"

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Cocktails"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        tableView = UITableView()
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CocktailTableViewCell.self, forCellReuseIdentifier: "CocktailCell")
    }

    private func bindViewModel() {
        viewModel.$cocktails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.showErrorAlert(message: errorMessage)
                }
            }
            .store(in: &cancellables)
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cocktails.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CocktailCell", for: indexPath) as? CocktailTableViewCell else {
            fatalError("Unable to dequeue CocktailTableViewCell")
        }
        let cocktail = viewModel.cocktails[indexPath.row]
        cell.configure(with: cocktail, isFavorite: viewModel.isFavorite(cocktail: cocktail))
        cell.favoriteAction = { [weak self] in
            self?.viewModel.toggleFavorite(cocktail: cocktail)
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cocktail = viewModel.cocktails[indexPath.row]
        let detailVC = CocktailDetailViewController(cocktailId: cocktail.idDrink)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // MARK: - UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {
        searchTimer?.invalidate()
        if let query = searchController.searchBar.text, !query.isEmpty {
            searchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                self?.viewModel.searchCocktails(query: query)
            }
        } else {
            viewModel.fetchCocktails()
        }
    }
}
