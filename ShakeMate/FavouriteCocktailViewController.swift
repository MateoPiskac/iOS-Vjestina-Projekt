//
//  FavouriteCocktailViewController.swift
//  ShakeMate
//
//  Created by Mateo Piskac on 11.07.2024..
//

import Foundation
import UIKit
import Combine
import Kingfisher
import PureLayout

class FavoriteCocktailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var tableView: UITableView!
    private var viewModel: FavoriteCocktailViewModel!
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    init(viewModel: FavoriteCocktailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        title = "Favorite Cocktails"
        view.backgroundColor = .white

        tableView = UITableView()
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CocktailTableViewCell.self, forCellReuseIdentifier: "CocktailCell")
    }

    private func bindViewModel() {
        viewModel.$favoriteCocktails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadFavorites()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favoriteCocktails.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CocktailCell", for: indexPath) as? CocktailTableViewCell else {
            fatalError("Unable to dequeue CocktailTableViewCell")
        }
        let cocktail = viewModel.favoriteCocktails[indexPath.row]
        cell.configure(with: cocktail, isFavorite: true)
        cell.favoriteAction = { [weak self] in
            self?.viewModel.removeFavorite(cocktail: cocktail)
            self?.tableView.reloadData()
        }
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cocktail = viewModel.favoriteCocktails[indexPath.row]
        let detailVC = CocktailDetailViewController(cocktailId: cocktail.idDrink)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
