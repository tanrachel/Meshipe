//
//  RecipeView.swift
//  Meshipe
//
//  Created by Rachel  Tan on 3/17/25.
//
import SwiftUI
import SwiftData

struct RecipeView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(GroqSession.self) var groq: GroqSession
    @Binding var navPath: NavigationPath
    @State var recipe: Recipe
    @State private var editMode: EditMode = .inactive
    @Binding var selectedTab: Int
    @State var presentGroqSheet = false
    @State var groqTailorSuccess = false
    @State var groqRecipe: Recipe? = nil
    init(navPath: Binding<NavigationPath>,  startEditing: Bool = false, recipe: Recipe, selectedTab: Binding<Int>) {
        self._recipe = State(wrappedValue: recipe)
        self._navPath = navPath
        self._editMode = State(initialValue: startEditing ? .active : .inactive)
        self._selectedTab = selectedTab
    }
    var body: some View {
            VStack(alignment: .leading) {
                if editMode == .active{
                    TextEditor(text: $recipe.title)
                        .padding()
                        .font(.title)
                        .frame(maxWidth: .infinity, maxHeight: 100, alignment: .top) // Set a max height

                }else{
                    Text(recipe.title)
                        .font(.title)
                        .padding()
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)

                }
                
                // Recipe List
                List {
                    // Ingredients Section
                    Section(header: Text("Ingredients").font(.headline)) {
                            ForEach(recipe.ingredients.indices, id: \.self) { index in
                                if index < recipe.ingredients.count {
                                    if editMode == .active {
                                        TextField("Enter ingredient", text: $recipe.ingredients[index])
                                    } else {
                                        Text(recipe.ingredients[index])
                                    }
                                    
                                }

                            }
                            .onDelete { indexSet in
                                recipe.ingredients.remove(atOffsets: indexSet)
                            }

                            if editMode == .active {
                                Button(action: addIngredient) {
                                    Label("Add Ingredient", systemImage: "plus.circle.fill")
                                }
                            }
                    }
                    


                    Section(header: Text("Instructions").font(.headline)) {
                        ForEach(recipe.instructions.indices, id: \.self) { index in
                            if index < recipe.instructions.count {
                                if editMode == .active {
                                    TextEditor(text: $recipe.instructions[index])
                                } else {
                                    Text(recipe.instructions[index])
                                }
                            }
                        }
                        .onDelete { indexSet in
                            recipe.instructions.remove(atOffsets: indexSet)
                        }
                        if editMode == .active {
                            Button(action: addInstructions) {
                                Label("Add Instruction", systemImage: "plus.circle.fill")
                            }
                        }
                    }
                    if editMode == .inactive{
                        Button("Tailor Recipe"){
                            presentGroqSheet.toggle()
                        }
                        .sheet(isPresented: $presentGroqSheet){
                            print("Sheet dismissed")
                            print(navPath)
                            if groqTailorSuccess, let groqRecipe = groqRecipe {
                                navPath.append(groqRecipe)
                            }
                            print(navPath)
                        } content: {
                            GroqRequestView(presentGroqSheet: $presentGroqSheet,oldRecipe: recipe, groqTailorSuccess: $groqTailorSuccess,  newRecipe: $groqRecipe)
                                .presentationDetents([.fraction(0.5)])
                            
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .environment(\.editMode, $editMode)
                .scrollContentBackground(.hidden)
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeView(navPath: $navPath, startEditing: true, recipe: recipe, selectedTab: $selectedTab)
            }


            .toolbar {
                Button(action: {
                    recipe.isFavorite.toggle()
                }) {
                    Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                        .resizable() // To allow resizing of the image
                        .aspectRatio(contentMode: .fit) // Maintain aspect ratio
                        .foregroundColor(recipe.isFavorite ? .darkBrown : .darkBrown)

                }
                Button(editMode == .active  ? "Save" : "Edit") {
                    withAnimation {
                        if editMode == .active {
                            removeEmptyRows()
                            modelContext.insert(recipe)
                        }
                        editMode = editMode == .active ? .inactive : .active
                    }
                    print("THis shoudl trigger after clicking save", editMode, selectedTab)
                    if editMode == .inactive && selectedTab == 1 {
                        selectedTab = 0
                        print("setting selectedTab", selectedTab)
                        
                    }
                }
                .buttonStyle(BrownButton())
            }
            .background(Color.lighterPastelYellow)
            .foregroundColor(Color.darkBrown)

        }


    private func addIngredient() {
        recipe.ingredients.append("")
    }
    private func addInstructions() {
        recipe.instructions.append("")
    }
    private func removeEmptyRows() {
        recipe.ingredients.removeAll { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        recipe.instructions.removeAll { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

}

#Preview {
    @Previewable @State var recipes = Recipe(title: "Chocolate Mousse", url: "www.test.com", ingredients: ["2 cups of chocolate", "1 block of tofu","2 tablespoon of maplesyrup"], instructions: ["melt chocolate first","blend tofu and melted chocolate together","chill in fridge overnight"])
    @Previewable @State var selectedTab = 0
    @Previewable @State var navpath = NavigationPath()
    let groqKey = ProcessInfo.processInfo.environment["groqkey"] ?? ""

    let mockGroqSession = GroqSession(api: groqKey)
    NavigationStack{
        RecipeView(navPath: $navpath, recipe: recipes,selectedTab: $selectedTab)
            .environment(mockGroqSession)
    }
}
