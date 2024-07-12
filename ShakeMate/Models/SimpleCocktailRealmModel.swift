//
//  SimpleCocktailRealmModel.swift
//  ShakeMate
//
//  Created by Mateo Piskac on 11.07.2024..
//

import Foundation
import RealmSwift

class SimpleCocktailRealmModel: Object {
    @objc dynamic var idDrink: String = ""
    @objc dynamic var strDrink: String = ""
    @objc dynamic var strDrinkThumb: String?

    override static func primaryKey() -> String? {
        return "idDrink"
    }
}
