//
//  ContentView.swift
//  BaseConverterApp
//
//  Created by Alexander Lee on 2/17/25.
//

import SwiftUI
import UIKit

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
    
    var body: some View {
        NavigationView {
            // Use GeometryReader for size information
            GeometryReader { geometry in
                VStack(spacing: 10) {
                    // Content section with input fields and messages
                    VStack(alignment: .leading, spacing: 4) {
                        BaseInputField(
                            title: "Base 2",
                            text: $viewModel.base2Input,
                            isValid: viewModel.isBase2Valid,
                            field: .base2,
                            viewModel: viewModel,
                            focusedField: _focusedField
                        )

                         BaseInputField(
                            title: "Base 8",
                            text: $viewModel.base8Input,
                            isValid: viewModel.isBase8Valid,
                            field: .base8,
                            viewModel: viewModel,
                            focusedField: _focusedField
                        )
                        
                        BaseInputField(
                            title: "Base 10",
                            text: $viewModel.base10Input,
                            isValid: viewModel.isBase10Valid,
                            field: .base10,
                            viewModel: viewModel,
                            focusedField: _focusedField
                        )
                        
                        BaseInputField(
                            title: "Base 12",
                            text: $viewModel.base12Input,
                            isValid: viewModel.isBase12Valid,
                            field: .base12,
                            viewModel: viewModel,
                            focusedField: _focusedField
                        )
                        
                        BaseInputField(
                            title: "Base 16",
                            text: $viewModel.base16Input,
                            isValid: viewModel.isBase16Valid,
                            field: .base16,
                            viewModel: viewModel,
                            focusedField: _focusedField
                        )
                        .frame(maxWidth: geometry.size.width - 32) // Fixed width based on screen
                    }
                    .padding(.horizontal)
                    .padding(.top, -50)
                    .frame(height: geometry.size.height * 0.50)
                    
                    // Add the custom keyboard at the bottom
                    CustomKeyboard(
                        onKeyTap: handleKeyTap,
                        focusedField: focusedField,
                        errorMessage: viewModel.errorMessage,
                        validationMessage: viewModel.validationMessage
                    )
                    .frame(height: geometry.size.height * 0.55)
                }
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
                    
                    // Add title to the center of the toolbar
                    ToolbarItem(placement: .principal) {
                        Text("Base Converter")
                            .font(.headline)
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
            case .base8:
                if !viewModel.base8Input.isEmpty {
                    viewModel.base8Input.removeLast()
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
            case .base8:
                if viewModel.base8Input.isEmpty {
                    viewModel.base8Input = "-"
                } else if viewModel.base8Input == "-" {
                    viewModel.base8Input = ""
                } else if viewModel.base8Input.hasPrefix("-") {
                    viewModel.base8Input.removeFirst()
                } else {
                    viewModel.base8Input = "-" + viewModel.base8Input
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
            // Check if the key is valid for the focused field and wouldn't exceed the maximum value
            switch focusedField {
            case .base2:
                if "01".contains(key) && viewModel.isWithinMaxValue(viewModel.base2Input + key, base: 2) {
                    viewModel.base2Input.append(key)
                }
            case .base8:
                if "01234567".contains(key) && viewModel.isWithinMaxValue(viewModel.base8Input + key, base: 8) {
                    viewModel.base8Input.append(key)
                }
            case .base10:
                if "0123456789".contains(key) && viewModel.isWithinMaxValue(viewModel.base10Input + key, base: 10) {
                    viewModel.base10Input.append(key)
                }
            case .base12:
                if "0123456789XE".contains(key) && viewModel.isWithinMaxValue(viewModel.base12Input + key, base: 12) {
                    viewModel.base12Input.append(key)
                }
            case .base16:
                if "0123456789ABCDEF".contains(key) && viewModel.isWithinMaxValue(viewModel.base16Input + key, base: 16) {
                    viewModel.base16Input.append(key)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
