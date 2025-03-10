//
//  ContentView.swift
//  BaseConverterApp
//
//  Created by Alexander Lee on 2/17/25.
//

import SwiftUI
import UIKit

struct BaseInputStyle: ViewModifier {
    let isValid: Bool
    let themeColor: Color
    
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.roundedBorder)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: isValid ? themeColor.opacity(0.2) : .red.opacity(0.2), radius: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isValid ? themeColor.opacity(0.5) : Color.red, lineWidth: 1)
            )
    }
}

struct BaseTheme {
    static let binary = Color.blue       // Binary feels technical, blue is appropriate
    static let decimal = Color.green     // Decimal is standard/natural, green works well
    static let duodecimal = Color.purple // Duodecimal is special/unique, purple fits
    static let hexadecimal = Color.orange // Hex is often used in web/design, orange is creative
}

struct ContentView: View {
    @StateObject private var viewModel = BaseConverterViewModel()
    
    // Add focus state to track which input is focused
    @FocusState private var focusedField: BaseField?
    
    // Enum to track which field is focused
    enum BaseField: Int, CaseIterable {
        case base2, base10, base12, base16
        
        var validCharacters: String {
            switch self {
            case .base2: return "01"
            case .base10: return "0123456789"
            case .base12: return "0123456789XE"
            case .base16: return "0123456789ABCDEF"
            }
        }
        
        var displayValidCharacters: String {
            switch self {
            case .base2: return "0, 1"
            case .base10: return "0-9"
            case .base12: return "0-9, X, E"
            case .base16: return "0-9, A-F"
            }
        }
        
        var description: String {
            switch self {
            case .base2: return "Binary"
            case .base10: return "Decimal"
            case .base12: return "Duodecimal"
            case .base16: return "Hexadecimal"
            }
        }
        
        var themeColor: Color {
            switch self {
            case .base2: return BaseTheme.binary
            case .base10: return BaseTheme.decimal
            case .base12: return BaseTheme.duodecimal
            case .base16: return BaseTheme.hexadecimal
            }
        }
    }
    
    var body: some View {
        NavigationView {
            // Use GeometryReader for size information
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Content section with input fields and messages
                    VStack(spacing: 8) {
                        // Number Bases Section
                        VStack(alignment: .leading, spacing: 6) {
                            baseInputField(
                                title: "Base 2 (Binary)",
                                text: $viewModel.base2Input,
                                isValid: viewModel.isBase2Valid,
                                field: .base2
                            )
                            
                            baseInputField(
                                title: "Base 10 (Decimal)",
                                text: $viewModel.base10Input,
                                isValid: viewModel.isBase10Valid,
                                field: .base10
                            )
                            
                            baseInputField(
                                title: "Base 12 (Duodecimal)",
                                text: $viewModel.base12Input,
                                isValid: viewModel.isBase12Valid,
                                field: .base12
                            )
                            
                            baseInputField(
                                title: "Base 16 (Hexadecimal)",
                                text: $viewModel.base16Input,
                                isValid: viewModel.isBase16Valid,
                                field: .base16
                            )
                        }
                        
                        // Messages Section - make this smaller and more compact
                        VStack(spacing: 2) {
                            if let errorMessage = viewModel.errorMessage {
                                MessageView(
                                    message: errorMessage,
                                    type: .error
                                )
                            }
                            
                            if let validationMessage = viewModel.validationMessage {
                                MessageView(
                                    message: validationMessage,
                                    type: .success
                                )
                            }
                        }
                        .frame(minHeight: 24) // Reduced minimum height
                        .padding(.top, 4)
                        
                        Spacer() // Push content to the top
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .frame(height: geometry.size.height * 0.55) // Top section takes 55% of screen
                    
                    // Add the custom keyboard at the bottom
                    CustomKeyboard(
                        onKeyTap: handleKeyTap,
                        focusedField: focusedField
                    )
                    .frame(height: geometry.size.height * 0.45) // Bottom keyboard takes 45% of screen
                }
                .navigationTitle("Base Converter")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: viewModel.reset) {
                            Label("Reset", systemImage: "arrow.clockwise.circle.fill")
                                .foregroundColor(Color.gray)
                        }
                        .foregroundColor(Color.gray)
                        .tint(Color.gray)
                        .accessibilityLabel("Reset all fields")
                    }
                }
            }
        }
    }
    
    private func baseInputField(
        title: String,
        text: Binding<String>,
        isValid: Bool,
        field: BaseField
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(field.themeColor)
                .dynamicTypeSize(.small ... .xxxLarge) // Enable Dynamic Type
            
            // Use our custom KeyboardDisabledTextField
            KeyboardDisabledTextField(
                text: text,
                placeholder: text.wrappedValue.isEmpty ? "Valid characters: \(field.displayValidCharacters)" : ""
            )
            .modifier(BaseInputStyle(isValid: isValid, themeColor: field.themeColor))
            .focused($focusedField, equals: field)
            .onChange(of: text.wrappedValue) { _ in
                viewModel.updateValidation()
            }
            .accessibilityLabel("\(field.description) input")
            .accessibilityValue(text.wrappedValue.isEmpty ? "Empty" : text.wrappedValue)
            .accessibilityHint("Tap to enter \(field.description) value. Valid characters are \(field.displayValidCharacters)")
        }
    }
    
    // Handle key taps from the custom keyboard
    private func handleKeyTap(_ key: String) {
        guard let focusedField = focusedField else { return }
        
        switch key {
        case "⌫": // Backspace
            // Handle backspace for each field
            switch focusedField {
            case .base2:
                if !viewModel.base2Input.isEmpty {
                    viewModel.base2Input.removeLast()
                }
            case .base10:
                if !viewModel.base10Input.isEmpty {
                    viewModel.base10Input.removeLast()
                }
            case .base12:
                if !viewModel.base12Input.isEmpty {
                    viewModel.base12Input.removeLast()
                }
            case .base16:
                if !viewModel.base16Input.isEmpty {
                    viewModel.base16Input.removeLast()
                }
            }
        case "-": // Handle negative sign
            // Only allow adding the negative sign at the beginning
            switch focusedField {
            case .base2:
                if viewModel.base2Input.isEmpty {
                    viewModel.base2Input = "-"
                } else if viewModel.base2Input == "-" {
                    // Remove the negative sign if it's already there
                    viewModel.base2Input = ""
                } else if viewModel.base2Input.hasPrefix("-") {
                    // Remove the negative sign if it's already there
                    viewModel.base2Input.removeFirst()
                } else {
                    // Add the negative sign at the beginning
                    viewModel.base2Input = "-" + viewModel.base2Input
                }
            case .base10:
                if viewModel.base10Input.isEmpty {
                    viewModel.base10Input = "-"
                } else if viewModel.base10Input == "-" {
                    viewModel.base10Input = ""
                } else if viewModel.base10Input.hasPrefix("-") {
                    viewModel.base10Input.removeFirst()
                } else {
                    viewModel.base10Input = "-" + viewModel.base10Input
                }
            case .base12:
                if viewModel.base12Input.isEmpty {
                    viewModel.base12Input = "-"
                } else if viewModel.base12Input == "-" {
                    viewModel.base12Input = ""
                } else if viewModel.base12Input.hasPrefix("-") {
                    viewModel.base12Input.removeFirst()
                } else {
                    viewModel.base12Input = "-" + viewModel.base12Input
                }
            case .base16:
                if viewModel.base16Input.isEmpty {
                    viewModel.base16Input = "-"
                } else if viewModel.base16Input == "-" {
                    viewModel.base16Input = ""
                } else if viewModel.base16Input.hasPrefix("-") {
                    viewModel.base16Input.removeFirst()
                } else {
                    viewModel.base16Input = "-" + viewModel.base16Input
                }
            }
        default: // Handle digit keys
            // Check if the key is valid for the focused field
            switch focusedField {
            case .base2:
                if "01".contains(key) {
                    viewModel.base2Input.append(key)
                }
            case .base10:
                if "0123456789".contains(key) {
                    viewModel.base10Input.append(key)
                }
            case .base12:
                if "0123456789XE".contains(key) {
                    viewModel.base12Input.append(key)
                }
            case .base16:
                if "0123456789ABCDEF".contains(key) {
                    viewModel.base16Input.append(key)
                }
            }
        }
    }
}

struct MessageView: View {
    let message: String
    let type: MessageType
    
    enum MessageType {
        case error
        case success
        
        var color: Color {
            switch self {
            case .error: return .red
            case .success: return .green
            }
        }
        
        var iconName: String {
            switch self {
            case .error: return "exclamationmark.triangle.fill"
            case .success: return "checkmark.circle.fill"
            }
        }
        
        var accessibilityAnnouncement: String {
            switch self {
            case .error: return "Error: "
            case .success: return "Success: "
            }
        }
    }
    
    var body: some View {
        // Simple horizontal layout with small icon and text
        HStack(spacing: 4) {
            Image(systemName: type.iconName)
                .font(.system(size: 12))
                .accessibilityHidden(true) // Hide from accessibility since it's decorative
            Text(message)
                .font(.caption)
                .dynamicTypeSize(.small ... .xxxLarge) // Enable Dynamic Type
        }
        .padding(.vertical, 2)
        .foregroundColor(type.color)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(type.accessibilityAnnouncement)\(message)")
    }
}

#Preview {
    ContentView()
}
