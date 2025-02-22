//
//  ContentView.swift
//  BaseConverterApp
//
//  Created by Alexander Lee on 2/17/25.
//

import SwiftUI

struct BaseInputStyle: ViewModifier {
    let isValid: Bool
    
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.roundedBorder)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: isValid ? .gray.opacity(0.2) : .red.opacity(0.2), radius: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isValid ? Color.gray.opacity(0.3) : Color.red, lineWidth: 1)
            )
    }
}

struct OperationButtonStyle: ButtonStyle {
    let systemImage: String
    let text: String
    let isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title2)
            Text(text)
                .font(.body)
        }
        .frame(minWidth: 100)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isEnabled ? Color.accentColor : Color.gray)
                .opacity(configuration.isPressed ? 0.7 : 1.0)
        )
        .foregroundColor(.white)
    }
}

struct ContentView: View {
    @StateObject private var viewModel = BaseConverterViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Number Bases Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Number Bases")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        baseInputField(
                            title: "Base 2 (Binary)",
                            text: $viewModel.base2Input,
                            isValid: viewModel.isBase2Valid,
                            validCharacters: "0, 1"
                        )
                        
                        baseInputField(
                            title: "Base 10 (Decimal)",
                            text: $viewModel.base10Input,
                            isValid: viewModel.isBase10Valid,
                            validCharacters: "0-9"
                        )
                        
                        baseInputField(
                            title: "Base 12 (Duodecimal)",
                            text: $viewModel.base12Input,
                            isValid: viewModel.isBase12Valid,
                            validCharacters: "0-9, A, B"
                        )
                        
                        baseInputField(
                            title: "Base 16 (Hexadecimal)",
                            text: $viewModel.base16Input,
                            isValid: viewModel.isBase16Valid,
                            validCharacters: "0-9, A-F"
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
                    
                    // Operations Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Operations")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            HStack(spacing: 20) {
                                operationButton(
                                    operation: .add,
                                    systemImage: "plus.circle.fill",
                                    text: "Add"
                                )
                                
                                operationButton(
                                    operation: .subtract,
                                    systemImage: "minus.circle.fill",
                                    text: "Subtract"
                                )
                            }
                            
                            HStack(spacing: 20) {
                                operationButton(
                                    operation: .multiply,
                                    systemImage: "multiply.circle.fill",
                                    text: "Multiply"
                                )
                                
                                operationButton(
                                    operation: .divide,
                                    systemImage: "divide.circle.fill",
                                    text: "Divide"
                                )
                            }
                        }
                        .padding()
                    }
                    
                    // Result Section
                    if let result = viewModel.operationResult {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Result")
                                .font(.headline)
                            
                            Text(result)
                                .font(.system(.title2, design: .monospaced))
                                .foregroundColor(.blue)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue.opacity(0.1))
                                )
                                .accessibilityLabel("Operation result")
                        }
                        .padding()
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
            .sheet(isPresented: $viewModel.showingOperationSheet) {
                OperationView(viewModel: viewModel)
            }
        }
    }
    
    private func baseInputField(
        title: String,
        text: Binding<String>,
        isValid: Bool,
        validCharacters: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField(title, text: text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                .modifier(BaseInputStyle(isValid: isValid))
                .onChange(of: text.wrappedValue) { _ in
                    viewModel.updateValidation()
                }
            
            Text("Valid characters: \(validCharacters)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    private func operationButton(
        operation: BaseConverterViewModel.Operation,
        systemImage: String,
        text: String
    ) -> some View {
        Button(action: {
            viewModel.startOperation(operation, from: 10)
        }) {
            EmptyView()
        }
        .buttonStyle(OperationButtonStyle(
            systemImage: systemImage,
            text: text,
            isEnabled: viewModel.errorMessage == nil
        ))
        .disabled(viewModel.errorMessage != nil)
        .accessibilityLabel("\(text) numbers")
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
    }
    
    var body: some View {
        HStack {
            Image(systemName: type.iconName)
            Text(message)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(type.color.opacity(0.1))
        )
        .foregroundColor(type.color)
        .padding(.horizontal)
    }
}

struct OperationView: View {
    @ObservedObject var viewModel: BaseConverterViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter Second Number")
                        .font(.headline)
                    
                    TextField("Second operand", text: $viewModel.secondOperand)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .modifier(BaseInputStyle(isValid: true))
                        .accessibilityLabel("Second operand input field")
                }
                .padding()
                
                if let errorMessage = viewModel.errorMessage {
                    MessageView(
                        message: errorMessage,
                        type: .error
                    )
                }
                
                Button(action: {
                    viewModel.performOperation()
                    dismiss()
                }) {
                    Text("Calculate")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.secondOperand.isEmpty ? Color.gray : Color.accentColor)
                        )
                }
                .disabled(viewModel.secondOperand.isEmpty)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Arithmetic Operation")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
