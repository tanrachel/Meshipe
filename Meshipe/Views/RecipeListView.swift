//
//  RecipeListView.swift
//  Meshipe
//
//  Created by Rachel  Tan on 3/16/25.
//

import SwiftUI
import SwiftData


struct RecipeListView: View {
    @Environment(GroqSession.self) var groq: GroqSession
    @Binding var navPath: NavigationPath
    @Query var recipes: [Recipe]
    @Binding var selectedTab: Int
    
    @State private var searchText = ""
    @State private var showFavoritesOnly = false

    var filteredRecipes: [Recipe] {
        if !searchText.isEmpty {
            return recipes.filter { recipe in
                recipe.title.localizedCaseInsensitiveContains(searchText) ||
                recipe.ingredients.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }) ||
                recipe.instructions.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
        if showFavoritesOnly {
            return recipes.filter { $0.isFavorite }
        }
        return recipes
    }
    var body: some View{
        VStack{
            List(filteredRecipes) { recipe in
                NavigationLink(destination: RecipeView(navPath: $navPath, recipe: recipe, selectedTab: $selectedTab)){
                    Text(recipe.title)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background(Color.lighterPastelYellow)
        .foregroundColor(Color.darkBrown)
        .searchable(text: $searchText, prompt: "Search for ...")
        .navigationTitle("Recipes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showFavoritesOnly.toggle()
                }) {
                    Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                        .foregroundColor(showFavoritesOnly ? .darkBrown : .gray)
                        .padding()
                }
            }
        }
        
    }
}

#Preview {
    @Previewable @State var testrecipes = [Recipe(title: "title2",url: "test2", ingredients: ["i1","i2","i3"], instructions: ["test2"]), Recipe(title: "title3", url: "test3",ingredients: ["i1","i2","i3"], instructions: ["test3"])]
    @Previewable @State var selectedTab = 0
    @Previewable @State var navPath = NavigationPath()
    let previewGroq = GroqSession(api: "test")

    NavigationStack(path: $navPath) {
        RecipeListView(navPath: $navPath, selectedTab: $selectedTab)
            .environment(previewGroq)
    }
    
}
