//
//  CocktailDetailsViewModel.swift
//  ShakeMate
//
//  Created by Mateo Piskac on 10.07.2024..
//

import Foundation
import Combine

class CocktailDetailViewModel: ObservableObject {
    @Published var cocktail: Cocktail?
    @Published var errorMessage: String? = nil
    private var cancellables = Set<AnyCancellable>()
    private let cocktailId: String

    init(cocktailId: String) {
        self.cocktailId = cocktailId
        fetchCocktailDetails()
    }

    func fetchCocktailDetails() {
        APIService.shared.fetchCocktailDetails(id: cocktailId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Successfully fetched cocktail details")
                case .failure(let error):
                    print("Error fetching cocktail details: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] cocktail in
                self?.cocktail = cocktail
            }
            .store(in: &cancellables)
    }
    
}
