//
//  CocktailListViewModel.swift
//  ShakeMate
//
//  Created by Mateo Piskac on 10.07.2024..
//

import Foundation
import Combine

class CocktailViewModel: ObservableObject {
    @Published var cocktails: [SimpleCocktail] = []
    @Published var errorMessage: String? = nil
    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchCocktails()
    }

    func fetchCocktails() {
            print("Starting fetchCocktails in ViewModel")
            APIService.shared.fetchCocktails()
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("Finished fetching cocktails in ViewModel")
                    case .failure(let error):
                        print("Error fetching cocktails in ViewModel: \(error.localizedDescription)")
                        self.errorMessage = error.localizedDescription
                    }
                } receiveValue: { [weak self] cocktails in
                    print("Received cocktails in ViewModel: \(cocktails)")
                    self?.updateCocktailsWithFavoriteStatus(cocktails: cocktails)
                }
                .store(in: &cancellables)
        }


        func searchCocktails(query: String) {
            APIService.shared.searchCocktails(query: query)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("Successfully searched cocktails")
                    case .failure(let error):
                        print("Error searching cocktails: \(error.localizedDescription)")
                        self.errorMessage = error.localizedDescription
                    }
                } receiveValue: { [weak self] cocktails in
                    print("Search results: \(cocktails)")
                    let simpleCocktails = cocktails.map { SimpleCocktail(idDrink: $0.idDrink, strDrink: $0.strDrink, strDrinkThumb: $0.strDrinkThumb) }
                    self?.updateCocktailsWithFavoriteStatus(cocktails: simpleCocktails)
                }
                .store(in: &cancellables)
        }

    private func updateCocktailsWithFavoriteStatus(cocktails: [SimpleCocktail]) {
            let favorites = APIService.shared.fetchFavorites()
            print("Favorite cocktails: \(favorites)")
            self.cocktails = cocktails.map { cocktail in
                let updatedCocktail = cocktail
                return updatedCocktail
            }
            print("Updated cocktails with favorite status: \(self.cocktails)")
        }

        func toggleFavorite(cocktail: SimpleCocktail) {
            if isFavorite(cocktail: cocktail) {
                APIService.shared.removeFavorite(cocktail: cocktail)
            } else {
                APIService.shared.saveFavorite(cocktail: cocktail)
            }
            fetchCocktails() // Refresh to update the favorite status
        }

        func isFavorite(cocktail: SimpleCocktail) -> Bool {
            let favorites = APIService.shared.fetchFavorites()
            return favorites.contains(where: { $0.idDrink == cocktail.idDrink })
        }
}
