//
//  ShoppingListView.swift
//  Meshipe
//
//  Created by Rachel  Tan on 3/24/25.
//

import SwiftUI
import SwiftData


struct ShoppingListView: View {
    @Environment(GroqSession.self) var groq: GroqSession

//    @ObservedObject var groq: GroqSession
    @Binding var groceryList: [GroceryItem]
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationStack {
            if groceryList.isEmpty{
                ShowRecipeOptionsView( groceryList: $groceryList)
            }else{
                ShowGroceryListView(groceryList: $groceryList)
            }
        }
    }
        

}


#Preview {
    @Previewable @State var testrecipes = [Recipe(title: "title2",url: "test2", ingredients: ["i1","i2","i3"], instructions: ["test2"]), Recipe(title: "title3", url: "test3",ingredients: ["i1","i2","i3"], instructions: ["test3"])]
    @Previewable @State var testList = [GroceryItem(item:"1 chocolate"), GroceryItem(item:"2 Tofu")]
    @Previewable @State var selectedTab = 0
    @Previewable @State var navPath = NavigationPath()
    let groqKey = ProcessInfo.processInfo.environment["groqkey"] ?? ""
    let mockGroqSession = GroqSession(api: groqKey)
    ShoppingListView( groceryList: $testList, selectedTab: $selectedTab)
        .environment(mockGroqSession)
        .modelContainer(.preview)

}
