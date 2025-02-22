//
//  ContentView.swift
//  BaseConverterApp
//
//  Created by Alexander Lee on 2/17/25.
//

import SwiftUI
import Combine

struct BaseInputStyle: ViewModifier {
    let isValid: Bool
    
    func body(content: Content) -> some View {
        content
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemBackground))
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
    let shortcut: String?
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title2)
            Text(text)
                .font(.body)
            if let shortcut = shortcut {
                Spacer()
                Text(shortcut)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
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
    @FocusState private var focusedField: InputField?
    
    enum InputField {
        case base2, base10, base12, base16
    }
    
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
                            validCharacters: "0, 1",
                            keyboardType: .numberPad,
                            field: .base2
                        )
                        
                        baseInputField(
                            title: "Base 10 (Decimal)",
                            text: $viewModel.base10Input,
                            isValid: viewModel.isBase10Valid,
                            validCharacters: "0-9",
                            keyboardType: .numberPad,
                            field: .base10
                        )
                        
                        baseInputField(
                            title: "Base 12 (Duodecimal)",
                            text: $viewModel.base12Input,
                            isValid: viewModel.isBase12Valid,
                            validCharacters: "0-9, A, B",
                            keyboardType: .asciiCapable,
                            field: .base12
                        )
                        
                        baseInputField(
                            title: "Base 16 (Hexadecimal)",
                            text: $viewModel.base16Input,
                            isValid: viewModel.isBase16Valid,
                            validCharacters: "0-9, A-F",
                            keyboardType: .asciiCapable,
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
                                    text: "Add",
                                    shortcut: "⌘+"
                                )
                                
                                operationButton(
                                    operation: .subtract,
                                    systemImage: "minus.circle.fill",
                                    text: "Subtract",
                                    shortcut: "⌘-"
                                )
                            }
                            
                            HStack(spacing: 20) {
                                operationButton(
                                    operation: .multiply,
                                    systemImage: "multiply.circle.fill",
                                    text: "Multiply",
                                    shortcut: "⌘*"
                                )
                                
                                operationButton(
                                    operation: .divide,
                                    systemImage: "divide.circle.fill",
                                    text: "Divide",
                                    shortcut: "⌘/"
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
                                .contextMenu {
                                    Button(action: {
                                        UIPasteboard.general.string = result
                                    }) {
                                        Label("Copy Result", systemImage: "doc.on.doc")
                                    }
                                }
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
                    .keyboardShortcut("r", modifiers: .command)
                    .accessibilityLabel("Reset all fields")
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Button(action: moveToPreviousField) {
                            Image(systemName: "chevron.up")
                        }
                        .disabled(!canMoveToPreviousField)
                        
                        Button(action: moveToNextField) {
                            Image(systemName: "chevron.down")
                        }
                        .disabled(!canMoveToNextField)
                        
                        Spacer()
                        
                        Button("Done") {
                            focusedField = nil
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingOperationSheet) {
                OperationView(viewModel: viewModel)
            }
            .onAppear {
                focusedField = .base10  // Focus decimal input by default
            }
            .onChange(of: focusedField) { _ in
                viewModel.updateValidation()
            }
            .keyboardShortcut("w", modifiers: .command) // Close sheet if open
        }
        .keyboardShortcuts()
    }
    
    private var canMoveToPreviousField: Bool {
        guard let current = focusedField else { return false }
        switch current {
        case .base2: return false
        case .base10: return true
        case .base12: return true
        case .base16: return true
        }
    }
    
    private var canMoveToNextField: Bool {
        guard let current = focusedField else { return false }
        switch current {
        case .base2: return true
        case .base10: return true
        case .base12: return true
        case .base16: return false
        }
    }
    
    private func moveToPreviousField() {
        guard let current = focusedField else { return }
        switch current {
        case .base2: break
        case .base10: focusedField = .base2
        case .base12: focusedField = .base10
        case .base16: focusedField = .base12
        }
    }
    
    private func moveToNextField() {
        guard let current = focusedField else { return }
        switch current {
        case .base2: focusedField = .base10
        case .base10: focusedField = .base12
        case .base12: focusedField = .base16
        case .base16: break
        }
    }
    
    private func baseInputField(
        title: String,
        text: Binding<String>,
        isValid: Bool,
        validCharacters: String,
        keyboardType: UIKeyboardType,
        field: InputField
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField(title, text: text)
                .focused($focusedField, equals: field)
                .keyboardType(keyboardType)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .modifier(BaseInputStyle(isValid: isValid))
                .onChange(of: text.wrappedValue) { _ in
                    viewModel.updateValidation()
                }
                .submitLabel(.next)
                .onSubmit {
                    moveToNextField()
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
        text: String,
        shortcut: String
    ) -> some View {
        Button(action: {
            viewModel.startOperation(operation, from: 10)
        }) {
            EmptyView()
        }
        .buttonStyle(OperationButtonStyle(
            systemImage: systemImage,
            text: text,
            isEnabled: viewModel.errorMessage == nil,
            shortcut: shortcut
        ))
        .disabled(viewModel.errorMessage != nil)
        .accessibilityLabel("\(text) numbers")
    }
}

extension View {
    func keyboardShortcuts() -> some View {
        self
            .keyboardShortcut("+", modifiers: .command) { // Add
                if let viewModel = (self as? ContentView)?._viewModel,
                   viewModel.errorMessage == nil {
                    viewModel.startOperation(.add, from: 10)
                }
            }
            .keyboardShortcut("-", modifiers: .command) { // Subtract
                if let viewModel = (self as? ContentView)?._viewModel,
                   viewModel.errorMessage == nil {
                    viewModel.startOperation(.subtract, from: 10)
                }
            }
            .keyboardShortcut("*", modifiers: .command) { // Multiply
                if let viewModel = (self as? ContentView)?._viewModel,
                   viewModel.errorMessage == nil {
                    viewModel.startOperation(.multiply, from: 10)
                }
            }
            .keyboardShortcut("/", modifiers: .command) { // Divide
                if let viewModel = (self as? ContentView)?._viewModel,
                   viewModel.errorMessage == nil {
                    viewModel.startOperation(.divide, from: 10)
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
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter Second Number")
                        .font(.headline)
                    
                    TextField("Second operand", text: $viewModel.secondOperand)
                        .focused($isInputFocused)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .modifier(BaseInputStyle(isValid: true))
                        .accessibilityLabel("Second operand input field")
                        .submitLabel(.done)
                        .onSubmit {
                            if !viewModel.secondOperand.isEmpty {
                                viewModel.performOperation()
                                dismiss()
                            }
                        }
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
                .keyboardShortcut(.return, modifiers: .command)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Arithmetic Operation")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            }
            .keyboardShortcut(.escape, modifiers: []))
            .onAppear {
                isInputFocused = true
            }
        }
    }
}

#Preview {
    ContentView()
}
