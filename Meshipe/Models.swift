//
//  Models.swift
//  Meshipe
//
//  Created by Rachel  Tan on 3/24/25.
//
import Foundation
import SwiftData

@Model
class Recipe: Identifiable, Hashable {
    var id: UUID = UUID()
    var title: String
    var url: String
    var isFavorite: Bool = false
    var isOnShoppingList: Bool = false
    var ingredients: [String]
    var instructions: [String]
    
    init(title: String, url: String="", ingredients: [String], instructions: [String]){
        self.title = title
        self.url = url
        self.ingredients = ingredients
        self.instructions = instructions
    }
}

struct RecipeJson: Decodable {
    let title: String
    let url: String
    let ingredients: [String]
    let instructions: [String]
}

struct GroceryItem: Identifiable, Hashable {
    let id = UUID()
    var item: String
}

struct GroceryJson: Decodable {
    let item: String
}

