//
//  FavouriteCocktailViewModel.swift
//  ShakeMate
//
//  Created by Mateo Piskac on 11.07.2024..
//

import Foundation
import Combine

class FavoriteCocktailViewModel: ObservableObject {
    @Published var favoriteCocktails: [SimpleCocktail] = []

    init() {
        loadFavorites()
    }

    func loadFavorites() {
        let favorites = APIService.shared.fetchFavorites()
        favoriteCocktails = favorites.map { cocktail in
            var updatedCocktail = cocktail
            return updatedCocktail
        }
    }

    func removeFavorite(cocktail: SimpleCocktail) {
        APIService.shared.removeFavorite(cocktail: cocktail)
        loadFavorites()
    }
}
