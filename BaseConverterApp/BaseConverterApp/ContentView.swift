//
//  ContentView.swift
//  BaseConverterApp
//
//  Created by Alexander Lee on 2/17/25.
//

import SwiftUI

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
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Number Bases Section
                        VStack(alignment: .leading, spacing: 16) {
                            baseInputField(
                                title: "Base 2 (Binary)",
                                text: $viewModel.base2Input,
                                isValid: viewModel.isBase2Valid,
                                validCharacters: "0, 1",
                                themeColor: BaseTheme.binary,
                                field: .base2
                            )
                            
                            baseInputField(
                                title: "Base 10 (Decimal)",
                                text: $viewModel.base10Input,
                                isValid: viewModel.isBase10Valid,
                                validCharacters: "0-9",
                                themeColor: BaseTheme.decimal,
                                field: .base10
                            )
                            
                            baseInputField(
                                title: "Base 12 (Duodecimal)",
                                text: $viewModel.base12Input,
                                isValid: viewModel.isBase12Valid,
                                validCharacters: "0-9, X, E",
                                themeColor: BaseTheme.duodecimal,
                                field: .base12
                            )
                            
                            baseInputField(
                                title: "Base 16 (Hexadecimal)",
                                text: $viewModel.base16Input,
                                isValid: viewModel.isBase16Valid,
                                validCharacters: "0-9, A-F",
                                themeColor: BaseTheme.hexadecimal,
                                field: .base16
                            )
                        }
                        .padding(.vertical)
                        
                        // Messages Section
                        VStack(spacing: 8) {
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
                    }
                    .padding()
                }
                .navigationTitle("Base Converter")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: viewModel.reset) {
                            Label("Reset", systemImage: "arrow.clockwise.circle.fill")
                        }
                        .accessibilityLabel("Reset all fields")
                    }
                    
                    // Add toolbar item to dismiss keyboard
                    ToolbarItem(placement: .keyboard) {
                        Button("Done") {
                            focusedField = nil
                        }
                    }
                }
                
                // Add the custom keyboard at the bottom
                CustomKeyboard(
                    onKeyTap: handleKeyTap,
                    focusedField: focusedField
                )
            }
        }
    }
    
    private func baseInputField(
        title: String,
        text: Binding<String>,
        isValid: Bool,
        validCharacters: String,
        themeColor: Color,
        field: BaseField
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(themeColor)
            
            TextField(title, text: text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                .modifier(BaseInputStyle(isValid: isValid, themeColor: themeColor))
                .focused($focusedField, equals: field)
                .onChange(of: text.wrappedValue) { _ in
                    viewModel.updateValidation()
                }
            
            Text("Valid characters: \(validCharacters)")
                .font(.caption)
                .foregroundColor(themeColor.opacity(0.8))
        }
        .padding(.horizontal)
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
        
        var backgroundColor: Color {
            switch self {
            case .error: return Color.red.opacity(0.1)
            case .success: return Color.green.opacity(0.1)
            }
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: type.iconName)
            Text(message)
                .foregroundColor(type.color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(type.backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(type.color.opacity(0.2), lineWidth: 1)
        )
        .foregroundColor(type.color)
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
