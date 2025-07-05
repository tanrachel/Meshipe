//
//  GroqRequestView.swift
//  Meshipe
//
//  Created by Rachel  Tan on 3/23/25.
//

import SwiftUI
import SwiftData

struct GroqRequestView: View {
    @Environment(GroqSession.self) var groq: GroqSession
    @State var trackTask: Task<Void,Error>? = nil
    @State var userInput: String = ""
    @Binding var presentGroqSheet: Bool
    @Bindable var oldRecipe: Recipe
    @State var errorMessage: String? = nil // To track and show errors
    @State var isLoading = false
    @Binding var groqTailorSuccess:Bool
    @Binding var newRecipe: Recipe?

    var body: some View {
        VStack{
            Text("Tailor Your Recipe")
                .font(.headline)
                .padding(.top)
            TextField("Enter what alterations you would like to make to the recipe!",text: $userInput)
                .textFieldStyle(.roundedBorder)
                .padding()
                .frame(height: UIScreen.main.bounds.height/6)
            Button("Send!"){
                isLoading = true
                trackTask?.cancel()
                trackTask = Task {
                    do{
                        if let recipe = try await groq.groqRecommendation(recipe: oldRecipe, userRequest: userInput){
                            newRecipe = recipe
                            groqTailorSuccess = true

                        }else{
                            errorMessage = "No recipe found."
                        }
                    }catch {
                        errorMessage = "Error: \(error.localizedDescription)"
                    }
                    isLoading = false
                    presentGroqSheet = false
                }
            }
            .buttonStyle(.borderedProminent)
            .font(.system(size: 20))
            .tint(.pink)
            if isLoading {
                 ProgressView("Loading...")
                     .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                     .padding()
             }
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top)
            }
        }

    }
}

#Preview {
    @Previewable @State var testRecipe = Recipe(title: "Chocolate Mousse", url: "www.test.com", ingredients: ["2 cups of chocolate", "1 block of tofu","2 tablespoon of maplesyrup"], instructions: ["melt chocolate first","blend tofu and melted chocolate together","chill in fridge overnight"])
    @Previewable @State var testBool = false
    @Previewable @State var groqRecipe : Recipe? = Recipe(title: "Chocolate Mousse", url: "www.test.com", ingredients: ["2 cups of chocolate", "1 block of tofu","2 tablespoon of maplesyrup"], instructions: ["melt chocolate first","blend tofu and melted chocolate together","chill in fridge overnight"])
    let groqKey = ProcessInfo.processInfo.environment["groqkey"] ?? ""

    let mockGroqSession = GroqSession(api: groqKey)
    GroqRequestView( userInput: "",presentGroqSheet: $testBool, oldRecipe: testRecipe, groqTailorSuccess: $testBool, newRecipe: $groqRecipe)
}
