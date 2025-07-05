//
//  ShoppingListRecipeOptionsView.swift
//  Meshipe
//
//  Created by Rachel  Tan on 4/14/25.
//
import SwiftUI
import SwiftData
struct ShowRecipeOptionsView: View {
    @Environment(GroqSession.self) var groq: GroqSession
    @Query var recipeList: [Recipe]
    @State private var selectedItems: Set<Recipe> = [] // Track selected items
    @Binding var groceryList: [GroceryItem]
    @State private var showAlert = false // State to control the alert visibility
    @State var trackTask: Task<Void,Error>? = nil
    @State var errorMessage: String? = nil // To track and show errors
    @State var isLoading = false
    var body: some View{
        VStack{
        
            List {
                ForEach(recipeList, id: \.self) { item in
                    HStack {
                        // Selection Indicator (Circle)
                        Image(systemName: selectedItems.contains(item) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedItems.contains(item) ? .yellow : .gray)
                            .onTapGesture {
                                toggleSelection(for: item)
                            }
                        
                        Text(item.title)
                            .onTapGesture {
                                toggleSelection(for: item)
                            }
                    }
                }
                
            }
            .scrollContentBackground(.hidden)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("No Recipes Selected"),
                    message: Text("Please select at least one recipe to generate the shopping list."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationTitle("Grocery List")
            if isLoading {
                 ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.darkBrown))
                     .padding()
             }
            Button(action: {
                if selectedItems.isEmpty {
                    showAlert = true
                } else {
                    isLoading = true
                    aggregateList()
                    selectedItems = []
                }
            }) {
                Image(systemName: "cart.fill") // Change icon as needed
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50) // Set size for the circular button
                    .padding() // Add padding to prevent touch issues
                    .background(Color.darkBrown) // Background color
                    .foregroundColor(Color.lighterPastelYellow) // Icon color
                    .clipShape(Circle()) // Makes it circular
                    .shadow(radius: 5) // Optional: adds a shadow effect
            }
            .padding(.bottom, 20)
        }
        .background(Color.lighterPastelYellow)
        .foregroundColor(Color.darkBrown)
    }
    private func toggleSelection(for item: Recipe) {
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
    }
    private func aggregateList() {
        var aggregateList: [GroceryItem] = []
        var stringList: [String] = []
        for item in selectedItems {
            for ingredient in item.ingredients {
                stringList.append(ingredient)
            }
        }
        trackTask?.cancel()
        trackTask = Task {
            do{
                if let list = try await groq.groqGrocery(groceryList: stringList){
                    for item in list{
                        aggregateList.append(GroceryItem(item: item))
                    }

                }else{
                    print("Somethng went wrong")
                    errorMessage = "No recipe found."
                }
            }catch {
                print("In catch")
                errorMessage = "Error: \(error.localizedDescription)"
            }
            isLoading = false
            groceryList = aggregateList
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
    ShowRecipeOptionsView(groceryList: $testList)
        .modelContainer(.preview)
        .environment(mockGroqSession)
}

extension ModelContainer {
    @MainActor
    static var preview: ModelContainer {
        let schema = Schema([Recipe.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])

        let context = container.mainContext
        let mockRecipes = [
            Recipe(title: "Spaghetti", url: "https://example.com/spaghetti", ingredients: ["Pasta", "Tomato"], instructions: ["Boil water", "Cook pasta"]),
            Recipe(title: "Tacos", url: "https://example.com/tacos", ingredients: ["Tortilla", "Beef","Tomato"], instructions: ["Cook beef", "Assemble tacos"]),
        ]

        for recipe in mockRecipes {
            context.insert(recipe)
        }

        return container
    }
}
