//
//  AddRecipeView.swift
//  Meshipe
//
//  Created by Rachel  Tan on 3/16/25.
//

import SwiftUI

struct AddRecipeView: View {
    @Environment(GroqSession.self) var groq: GroqSession

    @State var inputTextField: String = ""
    @State var trackTask: Task<Void,Error>? = nil
    @State var isLoading = false
    @State var errorMessage: String? = nil // To track and show errors
    @State var recipe: Recipe = Recipe(title: "Default", url: "Default", ingredients: [], instructions: [])
    @State var navigateToRecipeView: Bool = false
    @Binding var selectedTab: Int
    @State var navPath = NavigationPath()
    var body: some View{
        NavigationStack {
            ZStack{
                Color.lighterPastelYellow
                    .ignoresSafeArea()
                VStack{
//                    TextField("Enter Link",text: $inputTextField)
//                        .textFieldStyle(.roundedBorder)
//                        .font(.system(size: 20))
//                        .padding([.top,.bottom],5)
//                        .padding([.leading, .trailing], 20)
                    TextEditor(text: $inputTextField)
                        .frame(height: 100) // ~4 lines high
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.darkBrown, lineWidth: 2)
                        )
                        .padding([.leading, .trailing], 20)
                        .font(.system(size: 16))
                    Button("Import Recipe!"){
                        isLoading = true
                        trackTask?.cancel()
                        trackTask = Task {
                            do{
                                if let fetchedRecipe = try await groq.groqGetRecipe(link: inputTextField){
                                    recipe = fetchedRecipe
                                    navigateToRecipeView = true
                                }else{
                                    errorMessage = "No recipe found."
                                }
                            }catch {
                                errorMessage = "Error: \(error.localizedDescription)"
                            }
                            isLoading = false
                            
                        }
                    }
                    .buttonStyle(BrownButton())
                    .disabled(isLoading)
                    if isLoading {
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .padding()
                    }
                    
                }
                .navigationDestination(isPresented: $navigateToRecipeView) {
                    RecipeView(navPath: $navPath,  startEditing: true, recipe: recipe,selectedTab: $selectedTab)
                }
                .alert(isPresented: .constant(errorMessage != nil)){
                    Alert(title: Text("Error"),
                          message: Text(errorMessage ?? "Unknown Error"),
                          dismissButton: .default(Text("Ok"))
                    )
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var testrecipes: [Recipe] = []
    @Previewable @State var selectedTab = 1
    let groqKey = ProcessInfo.processInfo.environment["groqkey"] ?? ""
    let mockGroqSession = GroqSession(api: groqKey)

    AddRecipeView(selectedTab: $selectedTab)
        .environment(mockGroqSession)
}
