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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Number Bases Section
                    VStack(alignment: .leading, spacing: 16) {
                        baseInputField(
                            title: "Base 2 (Binary)",
                            text: $viewModel.base2Input,
                            isValid: viewModel.isBase2Valid,
                            validCharacters: "0, 1",
                            themeColor: BaseTheme.binary
                        )
                        
                        baseInputField(
                            title: "Base 10 (Decimal)",
                            text: $viewModel.base10Input,
                            isValid: viewModel.isBase10Valid,
                            validCharacters: "0-9",
                            themeColor: BaseTheme.decimal
                        )
                        
                        baseInputField(
                            title: "Base 12 (Duodecimal)",
                            text: $viewModel.base12Input,
                            isValid: viewModel.isBase12Valid,
                            validCharacters: "0-9, X, E",
                            themeColor: BaseTheme.duodecimal
                        )
                        
                        baseInputField(
                            title: "Base 16 (Hexadecimal)",
                            text: $viewModel.base16Input,
                            isValid: viewModel.isBase16Valid,
                            validCharacters: "0-9, A-F",
                            themeColor: BaseTheme.hexadecimal
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
            }
        }
    }
    
    private func baseInputField(
        title: String,
        text: Binding<String>,
        isValid: Bool,
        validCharacters: String,
        themeColor: Color
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
                .onChange(of: text.wrappedValue) { _ in
                    viewModel.updateValidation()
                }
            
            Text("Valid characters: \(validCharacters)")
                .font(.caption)
                .foregroundColor(themeColor.opacity(0.8))
        }
        .padding(.horizontal)
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
