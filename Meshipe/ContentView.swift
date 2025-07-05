//
//  ContentView.swift
//  Meshipe
//
//  Created by Rachel  Tan on 3/16/25.
//

import SwiftUI
import GroqSwift
import SwiftData

struct ContentView: View {
    @Environment(GroqSession.self) var groq: GroqSession
    @Environment(\.modelContext) var modelContext
    @Query var recipeList: [Recipe]
    @State var groceryList:[GroceryItem] = []
    @State var selectedTab = 0
    @State private var navPath = NavigationPath()
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color.pastelYellow)
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.darkBrown)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.darkBrown)]

    }
    var body: some View {
        TabView(selection: $selectedTab){
            NavigationStack(path: $navPath) {
                RecipeListView( navPath: $navPath, selectedTab: $selectedTab)
            }
            .tabItem{
                Label("Recipe", systemImage: "list.bullet.rectangle.portrait.fill" )
            }
            .tag(0)

            AddRecipeView(selectedTab: $selectedTab)
                .tabItem{
                    Label("Import", systemImage: "plus")
                }
                .tag(1)
            ShoppingListView(groceryList: $groceryList,selectedTab: $selectedTab)
                .tabItem{Label("List", systemImage: "checklist")}
                .tag(2)
        }
        .tint(Color.darkBrown)

    }
}

#Preview {
    let previewGroq = GroqSession(api: "test")

    ContentView()
        .environment(previewGroq)
        
}
