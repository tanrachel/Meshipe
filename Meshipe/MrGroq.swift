//
//  MrGroq.swift
//  Meshipe
//
//  Created by Rachel  Tan on 3/17/25.
//
import Foundation
import SwiftSoup
import GroqSwift

enum GroqError: Error {
    case badURL
    case badServerResponse
    case contentDecodingFailed
    case recipeNotFound
}

@Observable
@MainActor
final class GroqSession {
    private var groqClient: GroqClient
    init(api: String) {
        self.groqClient = GroqClient(apiKey: api)
    }
    public func groqGetRecipe(link: String) async throws -> Recipe? {
        do {
            guard let htmlContent = try await getRecipeContent(link: link) else {
                throw GroqError.recipeNotFound
            }

            guard let jsonRecipe = try await groqRecipeContent(htmlContent: htmlContent) else {
                throw GroqError.recipeNotFound
            }

            return Recipe(title: jsonRecipe.title, url: jsonRecipe.url, ingredients: jsonRecipe.ingredients, instructions: jsonRecipe.instructions)

        } catch let error as URLError {
            switch error.code {
            case .badURL:
                throw GroqError.badURL
            case .badServerResponse:
                throw GroqError.badServerResponse
            case .cannotDecodeContentData:
                throw GroqError.contentDecodingFailed
            default:
                throw error
            }
        }
    }
    private func getRecipeContent(link: String) async throws -> String? {
        guard let url = URL(string:link) else{
            throw URLError(.badURL)
        }
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data,response) = try await URLSession.shared.data(for: request)
        guard let httpReponse = response as? HTTPURLResponse, httpReponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        guard let htmlContent = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }
        var result = "url: \(link) \n"
        let document: Document = try SwiftSoup.parse(htmlContent)
        if let body = document.body() {
            let displayedText = try body.text()
            result += displayedText
            result += "\n"
        } else {
            print("No body content found")
        }
        print("==== BEGIN HTML RESULT ==== ")
        print(result)
        print("==== END HTML RESULT ==== ")

        return result
    }
    public func groqRecommendation(recipe: Recipe, userRequest: String) async throws -> Recipe? {
        let request = ChatCompletionRequest(
            model: .llama70bVersatile,
            messages: [
                       Message(role: .user, content:
                                """
                               Given this list of ingredients: \(recipe.ingredients) and these instructions: \(recipe.instructions), tailor the recipe according to this request: \(userRequest). Return json in this format: title: String. url: String, ingredients: [String] must contain quantity/amount and only ingredients one would purchase at a grocery store. instructions: [String] should contain instructions without numerical bulletpoints.
                               """)],
            temperature: 0.7
        )
        let response = try await groqClient.createChatCompletion(request)
        guard let jsonString = response.choices.first?.message.content else {
            throw URLError(.badServerResponse)
        }
        guard let recipeJsonData = extractJSON(jsonString) else{
            throw URLError(.cannotDecodeRawData)
        }
        guard let recipe = try? JSONDecoder().decode(RecipeJson.self, from: recipeJsonData) else{
            throw URLError(.cannotDecodeContentData)
        }
        print(jsonString)
        print("==== BEGIN GROQ RESULT ==== ")
        print(recipe)
        print("==== END GROQ RESULT ==== ")

        return Recipe(title: recipe.title, url: recipe.url, ingredients: recipe.ingredients, instructions: recipe.instructions)

    }
    
    public func groqGrocery(groceryList: [String]) async throws -> [String]? {
        let request = ChatCompletionRequest(
            model: .llama70bVersatile,
            messages: [
                Message(role: .system, content: "You are helping the user create a clean grocery list. Given that the user has dumped different ingredients from multiple recipes, aggregate them into one concise list with quantities. Return only a JSON array of strings. Give the format of each grocery item as quantity unit ingredient in this specific order"),
                Message(role: .user, content:
                    """
                    Given this list of ingredients: \(groceryList), aggregate them so that each row is a unique item with quantity to purchase. Return as a JSON array of strings.
                    """)
            ],
            temperature: 0.7
        )

        let response = try await groqClient.createChatCompletion(request)

        guard let jsonString = response.choices.first?.message.content else {
            throw URLError(.badServerResponse)
        }

        print("== RAW GROQ GROCERY OUTPUT ==")
        print(jsonString)

        guard let jsonData = extractJSONArray(jsonString) else {
            throw URLError(.cannotDecodeRawData)
        }

        do {
            let decodedList = try JSONDecoder().decode([String].self, from: jsonData)
            return decodedList
        } catch {
            print("Failed to decode JSON: \(error.localizedDescription)")
            throw URLError(.cannotDecodeContentData)
        }
    }

    
    private func groqRecipeContent(htmlContent: String) async throws -> RecipeJson? {
        let request = ChatCompletionRequest(
            model: .llama70bVersatile,
            messages: [
                       Message(role: .user, content:
                                """
                               Extract the title, url , ingredients and the instructions for only the main dish and return json. title: String. url: String, ingredients: [String] must contain quantity/amount and only ingredients one would purchase at a grocery store. instructions: [String] should contain instructions without numerical bulletpoints: 
                               \(htmlContent)
                               """)],
            temperature: 0.7
        )
        let response = try await groqClient.createChatCompletion(request)
        guard let jsonString = response.choices.first?.message.content else {
            throw URLError(.badServerResponse)
        }
        guard let recipeJsonData = extractJSON(jsonString) else{
            throw URLError(.cannotDecodeRawData)
        }
        guard let recipe = try? JSONDecoder().decode(RecipeJson.self, from: recipeJsonData) else{
            throw URLError(.cannotDecodeContentData)
        }
        return recipe
    }
    private func extractJSON(_ string: String) -> Data? {
        let pattern = "\\{[^}]*\\}"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        
        let range = NSRange(location: 0, length: string.utf16.count)
        
        if let match = regex.firstMatch(in: string, options: [], range: range) {
            let matchRange = match.range(at: 0)
            let jsonString = (string as NSString).substring(with: matchRange)
            return jsonString.data(using: .utf8)

        }
        
        return nil
    }
    private func extractJSONArray(_ string: String) -> Data? {
        let pattern = "\\[[\\s\\S]*?\\]" // matches the outermost JSON array
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }
        let range = NSRange(location: 0, length: string.utf16.count)
        if let match = regex.firstMatch(in: string, options: [], range: range) {
            let matchRange = match.range(at: 0)
            let jsonString = (string as NSString).substring(with: matchRange)
            return jsonString.data(using: .utf8)
        }
        return nil
    }
}
