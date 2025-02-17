//
//  ContentView.swift
//  BaseConverterApp
//
//  Created by Alexander Lee on 2/17/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BaseConverterViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Number Bases")) {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Base 2 (Binary)", text: $viewModel.base2Input)
                            .keyboardType(.numberPad)
                            .accessibilityLabel("Base 2 input field")
                            .foregroundColor(viewModel.isBase2Valid ? .primary : .red)
                            .onChange(of: viewModel.base2Input) { _ in
                                viewModel.updateValidation()
                            }
                        Text("Valid characters: 0, 1")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Base 10 (Decimal)", text: $viewModel.base10Input)
                            .keyboardType(.numberPad)
                            .accessibilityLabel("Base 10 input field")
                            .foregroundColor(viewModel.isBase10Valid ? .primary : .red)
                            .onChange(of: viewModel.base10Input) { _ in
                                viewModel.updateValidation()
                            }
                        Text("Valid characters: 0-9")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Base 12 (Duodecimal)", text: $viewModel.base12Input)
                            .keyboardType(.asciiCapable)
                            .accessibilityLabel("Base 12 input field")
                            .foregroundColor(viewModel.isBase12Valid ? .primary : .red)
                            .onChange(of: viewModel.base12Input) { _ in
                                viewModel.updateValidation()
                            }
                        Text("Valid characters: 0-9, A, B")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Base 16 (Hexadecimal)", text: $viewModel.base16Input)
                            .keyboardType(.asciiCapable)
                            .accessibilityLabel("Base 16 input field")
                            .foregroundColor(viewModel.isBase16Valid ? .primary : .red)
                            .onChange(of: viewModel.base16Input) { _ in
                                viewModel.updateValidation()
                            }
                        Text("Valid characters: 0-9, A-F")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .accessibilityLabel("Error message")
                    }
                }
                
                if let validationMessage = viewModel.validationMessage {
                    Section {
                        Text(validationMessage)
                            .foregroundColor(.green)
                            .accessibilityLabel("Validation message")
                    }
                }
                
                Section(header: Text("Operations")) {
                    HStack {
                        Button(action: {
                            viewModel.startOperation(.add, from: 10)
                        }) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add")
                        }
                        .accessibilityLabel("Add numbers")
                        .disabled(viewModel.errorMessage != nil)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.startOperation(.subtract, from: 10)
                        }) {
                            Image(systemName: "minus.circle.fill")
                            Text("Subtract")
                        }
                        .accessibilityLabel("Subtract numbers")
                        .disabled(viewModel.errorMessage != nil)
                    }
                    
                    HStack {
                        Button(action: {
                            viewModel.startOperation(.multiply, from: 10)
                        }) {
                            Image(systemName: "multiply.circle.fill")
                            Text("Multiply")
                        }
                        .accessibilityLabel("Multiply numbers")
                        .disabled(viewModel.errorMessage != nil)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.startOperation(.divide, from: 10)
                        }) {
                            Image(systemName: "divide.circle.fill")
                            Text("Divide")
                        }
                        .accessibilityLabel("Divide numbers")
                        .disabled(viewModel.errorMessage != nil)
                    }
                }
                
                if let result = viewModel.operationResult {
                    Section(header: Text("Result")) {
                        Text(result)
                            .font(.title2)
                            .foregroundColor(.blue)
                            .accessibilityLabel("Operation result")
                    }
                }
            }
            .navigationTitle("Base Converter")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.reset) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                        Text("Reset")
                    }
                    .accessibilityLabel("Reset all fields")
                }
            }
            .sheet(isPresented: $viewModel.showingOperationSheet) {
                OperationView(viewModel: viewModel)
            }
        }
    }
}

struct OperationView: View {
    @ObservedObject var viewModel: BaseConverterViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter Second Number")) {
                    TextField("Second operand", text: $viewModel.secondOperand)
                        .keyboardType(.numberPad)
                        .accessibilityLabel("Second operand input field")
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .accessibilityLabel("Operation error message")
                    }
                }
                
                Section {
                    Button("Calculate") {
                        viewModel.performOperation()
                        dismiss()
                    }
                    .disabled(viewModel.secondOperand.isEmpty)
                }
            }
            .navigationTitle("Arithmetic Operation")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}

#Preview {
    ContentView()
}
