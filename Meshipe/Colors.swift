//
//  Colors.swift
//  Meshipe
//
//  Created by Rachel  Tan on 3/30/25.
//
import SwiftUI

extension Color {
    static let pastelYellow = Color(UIColor(red: 0.98, green: 0.89, blue: 0.55, alpha: 1.0)) // Extracted from Senshi image
}
extension Color {
    static let darkBrown = Color(red: 95 / 255, green: 58 / 255, blue: 44 / 255)

}
extension Color {
    static let lighterPastelYellow = Color(UIColor(red: 0.99, green: 0.93, blue: 0.68, alpha: 1.0))
}

struct BrownButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal,16)
            .padding(.vertical,8)// Default padding size for the button
            .background(Color.darkBrown)
            .foregroundColor(Color.lighterPastelYellow)  // Adjust text color
            .clipShape(RoundedRectangle(cornerRadius: 8))  // Slightly rounded corners
            .scaleEffect(configuration.isPressed ? 0.95 : 1)  // Slightly shrink the button when pressed
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)  // Smooth transition
    }
}
