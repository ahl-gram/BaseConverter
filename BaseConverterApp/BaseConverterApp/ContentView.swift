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
                            // Add action
                        }) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add")
                        }
                        .accessibilityLabel("Add numbers")
                        .disabled(viewModel.errorMessage != nil)
                        
                        Spacer()
                        
                        Button(action: {
                            // Subtract action
                        }) {
                            Image(systemName: "minus.circle.fill")
                            Text("Subtract")
                        }
                        .accessibilityLabel("Subtract numbers")
                        .disabled(viewModel.errorMessage != nil)
                    }
                    
                    HStack {
                        Button(action: {
                            // Multiply action
                        }) {
                            Image(systemName: "multiply.circle.fill")
                            Text("Multiply")
                        }
                        .accessibilityLabel("Multiply numbers")
                        .disabled(viewModel.errorMessage != nil)
                        
                        Spacer()
                        
                        Button(action: {
                            // Divide action
                        }) {
                            Image(systemName: "divide.circle.fill")
                            Text("Divide")
                        }
                        .accessibilityLabel("Divide numbers")
                        .disabled(viewModel.errorMessage != nil)
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
        }
    }
}

#Preview {
    ContentView()
}
