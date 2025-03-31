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
            .frame(height: 60)  // Set a fixed height for the input field container
            .frame(maxWidth: .infinity) // Enforce maximum width constraint
            .fixedSize(horizontal: false, vertical: true) // Only allow vertical growth
            .clipShape(RoundedRectangle(cornerRadius: 10))  // Ensure content is clipped to the container
    }
}

struct BaseTheme {
    static let binary = Color.blue       // Binary feels technical, blue is appropriate
    static let decimal = Color.green     // Decimal is standard/natural, green works well
    static let duodecimal = Color.purple // Duodecimal is special/unique, purple fits
    static let hexadecimal = Color.orange // Hex is often used in web/design, orange is creative
}

struct ContentView: View {
    @StateObject var viewModel: BaseConverterViewModel
    
    // State to control the About sheet
    @State private var showingAbout = false
    
    // Default initializer for normal app usage
    init() {
        self._viewModel = StateObject(wrappedValue: BaseConverterViewModel())
    }
    
    // Testing initializer that accepts a pre-created viewModel
    init(viewModel: BaseConverterViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // Add focus state to track which input is focused
    @FocusState var focusedField: BaseField?
    
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
                    VStack(spacing: 4) {
                        // Number Bases Section
                        VStack(alignment: .leading, spacing: 4) {
                            baseInputField(
                                title: "Base 2",
                                text: $viewModel.base2Input,
                                isValid: viewModel.isBase2Valid,
                                field: .base2
                            )
                            
                            baseInputField(
                                title: "Base 10",
                                text: $viewModel.base10Input,
                                isValid: viewModel.isBase10Valid,
                                field: .base10
                            )
                            
                            baseInputField(
                                title: "Base 12",
                                text: $viewModel.base12Input,
                                isValid: viewModel.isBase12Valid,
                                field: .base12
                            )
                            
                            baseInputField(
                                title: "Base 16",
                                text: $viewModel.base16Input,
                                isValid: viewModel.isBase16Valid,
                                field: .base16
                            )
                        }
                        .frame(maxWidth: geometry.size.width - 32) // Fixed width based on screen
                        
                        Spacer() // Push content to the top
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .frame(height: geometry.size.height * 0.50)
                    
                    // Add the custom keyboard at the bottom
                    CustomKeyboard(
                        onKeyTap: handleKeyTap,
                        focusedField: focusedField,
                        errorMessage: viewModel.errorMessage,
                        validationMessage: viewModel.validationMessage
                    )
                    .frame(height: geometry.size.height * 0.50)
                }
                .navigationTitle("Base Converter")
                .toolbar {
                    // Add info button to leading edge of toolbar
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showingAbout = true
                        }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.gray)
                        }
                        .accessibilityLabel("About")
                    }
                    
                    // Keep existing reset button in trailing position
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            // Add haptic feedback when reset button is tapped
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            
                            viewModel.reset()
                        }) {
                            Label("Reset", systemImage: "arrow.counterclockwise.circle.fill")
                                .foregroundColor(Color.gray)
                        }
                        .foregroundColor(Color.gray)
                        .tint(Color.gray)
                        .accessibilityLabel("Reset all fields")
                    }
                }
                .sheet(isPresented: $showingAbout) {
                    AboutView()
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
            
            // Use our custom CustomKeyboardTextField
            CustomKeyboardTextField(
                text: text,
                placeholder: text.wrappedValue.isEmpty ? "\(field.description)" : ""
            )
            .modifier(BaseInputStyle(isValid: isValid, themeColor: field.themeColor))
            .dynamicTypeSize(.small ... .xxxLarge) // Enable Dynamic Type for input field
            .focused($focusedField, equals: field)
            .onChange(of: text.wrappedValue) { _ in
                viewModel.updateValidation()
            }
            .accessibilityLabel("\(field.description) input")
            .accessibilityValue(text.wrappedValue.isEmpty ? "Empty" : text.wrappedValue)
            .accessibilityHint("Tap to enter \(field.description) value. Valid characters are \(field.displayValidCharacters)")
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true) // Only allow vertical growth
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true) // Also constrain the parent
    }
    
    // Handle key taps from the custom keyboard
    private func handleKeyTap(_ key: String) {
        guard let focusedField = focusedField else { return }
        
        // Define a maximum character limit to prevent overflow
        let maxCharLimit = 20
        
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
        case "INCREMENT": // Handle incrementing value
            viewModel.incrementValue()
        case "DECREMENT": // Handle decrementing value
            viewModel.decrementValue()
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
            // Check if the key is valid for the focused field and under the character limit
            switch focusedField {
            case .base2:
                if "01".contains(key) && viewModel.base2Input.count < maxCharLimit {
                    viewModel.base2Input.append(key)
                }
            case .base10:
                if "0123456789".contains(key) && viewModel.base10Input.count < maxCharLimit {
                    viewModel.base10Input.append(key)
                }
            case .base12:
                if "0123456789XE".contains(key) && viewModel.base12Input.count < maxCharLimit {
                    viewModel.base12Input.append(key)
                }
            case .base16:
                if "0123456789ABCDEF".contains(key) && viewModel.base16Input.count < maxCharLimit {
                    viewModel.base16Input.append(key)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
