//
//  APIService.swift
//  ShakeMate
//
//  Created by Mateo Piskac on 10.07.2024..
//

import Foundation
import Combine
import RealmSwift

class APIService {
    static let shared = APIService()
    private let baseURL = "https://www.thecocktaildb.com/api/json/v1/1"
    private let realm = try! Realm()

    private init() {}

    func fetchCocktails() -> AnyPublisher<[SimpleCocktail], Error> {
            let url = URL(string: "\(baseURL)/filter.php?a=Alcoholic")!
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .handleEvents(receiveOutput: { data in
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Fetch Cocktails JSON Response: \(jsonString)")
                    }
                })
                .tryMap { data -> [SimpleCocktail] in
                    let decoder = JSONDecoder()
                    do {
                        let response = try decoder.decode(SimpleCocktailResponse.self, from: data)
                        return response.drinks
                    } catch {
                        print("Decoding error: \(error.localizedDescription)")
                        throw error
                    }
                }
                .eraseToAnyPublisher()
        }

        func searchCocktails(query: String) -> AnyPublisher<[Cocktail], Error> {
            let url = URL(string: "\(baseURL)/search.php?s=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .handleEvents(receiveOutput: { data in
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Search Cocktails JSON Response: \(jsonString)")
                    }
                })
                .decode(type: CocktailResponse.self, decoder: JSONDecoder())
                .map { $0.drinks }
                .eraseToAnyPublisher()
        }


    func fetchCocktailDetails(id: String) -> AnyPublisher<Cocktail, Error> {
        guard let url = URL(string: "\(baseURL)/lookup.php?i=\(id)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .handleEvents(receiveOutput: { data in
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Received data: \(jsonString)")
                }
            })
            .decode(type: CocktailResponse.self, decoder: JSONDecoder())
            .map { $0.drinks.first! } // assuming that the response always contains at least one drink
            .eraseToAnyPublisher()
    }
    
    func saveFavorite(cocktail: SimpleCocktail) {
            let realmCocktail = SimpleCocktailRealmModel()
            realmCocktail.idDrink = cocktail.idDrink
            realmCocktail.strDrink = cocktail.strDrink
            realmCocktail.strDrinkThumb = cocktail.strDrinkThumb

            try! realm.write {
                realm.add(realmCocktail, update: .modified)
            }
        }

        func removeFavorite(cocktail: SimpleCocktail) {
            if let realmCocktail = realm.object(ofType: SimpleCocktailRealmModel.self, forPrimaryKey: cocktail.idDrink) {
                try! realm.write {
                    realm.delete(realmCocktail)
                }
            }
        }

        func fetchFavorites() -> [SimpleCocktail] {
            let realmCocktails = realm.objects(SimpleCocktailRealmModel.self)
            return realmCocktails.map {
                SimpleCocktail(idDrink: $0.idDrink, strDrink: $0.strDrink, strDrinkThumb: $0.strDrinkThumb)
            }
        }
    
    func isFavorite(cocktailID: String) -> Bool {
            return realm.object(ofType: SimpleCocktailRealmModel.self, forPrimaryKey: cocktailID) != nil
        }
    }
