import SwiftUI

struct CustomKeyboard: View {
    // Callback function to handle keyboard input
    var onKeyTap: (String) -> Void
    // Currently focused field (if any)
    var focusedField: ContentView.BaseField?
    // Add message parameters
    var errorMessage: String?
    var validationMessage: String?
    
    // Function to determine the color of each key based on what bases it's used in
    func colorForKey(_ key: String) -> Color {
        switch key {
        case "0", "1":
            // Used in all bases, use binary color as most restrictive
            return BaseTheme.binary
        case "2", "3", "4", "5", "6", "7", "8", "9":
            // Used in base 10, 12, and 16
            return BaseTheme.decimal
        case "X", "E_DUO": // Using E_DUO to distinguish duodecimal E
            // Used only in base 12
            return BaseTheme.duodecimal
        case "A", "B", "C", "D", "E_HEX", "F": // Using E_HEX to distinguish hexadecimal E
            // Used only in base 16
            return BaseTheme.hexadecimal
        default:
            return .gray
        }
    }
    
    // Check if a key is valid for the currently focused field
    func isKeyValid(_ key: String) -> Bool {
        guard let field = focusedField else {
            return false // No focused field, all keys are disabled
        }
        
        if key == "⌫" || key == "-" {
            return true // Backspace and negative are always valid
        }
        
        // Handle special cases for E
        if key == "E_DUO" {
            return field == .base12 // Only enabled for base 12
        }
        
        if key == "E_HEX" {
            return field == .base16 // Only enabled for base 16
        }
        
        // For regular keys, check if they're in the valid characters list
        let actualKey = key == "E_DUO" || key == "E_HEX" ? "E" : key // Convert back to regular E for validation
        return field.validCharacters.contains(actualKey)
    }
    
    // Helper to convert special key identifiers back to actual characters
    func displayKey(_ key: String) -> String {
        switch key {
        case "E_DUO", "E_HEX":
            return "E"
        default:
            return key
        }
    }
    
    // Helper to send the correct key for taps
    func handleKeyTap(_ key: String) {
        let actualKey = displayKey(key)
        onKeyTap(actualKey)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Show current mode and messages at the top of the keyboard
            HStack(alignment: .center) {
                // Current mode info on left - explicitly left-aligned
                HStack {
                    if let field = focusedField {
                        Text("Current mode: \(field.description)")
                            .font(.caption)
                            .foregroundColor(field.themeColor)
                    } else {
                        Text("Tap a field to begin entering values")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer(minLength: 0) // Forces left alignment
                }
                
                Spacer()
                
                // Messages on right - show only icons, vertically centered
                if let errorMessage = errorMessage {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                        .accessibilityLabel("Error: \(errorMessage)")
                        .frame(height: 20, alignment: .center) // Ensure vertical centering
                } else if let validationMessage = validationMessage {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                        .accessibilityLabel("Success: \(validationMessage)")
                        .frame(height: 20, alignment: .center) // Ensure vertical centering
                }
            }
            .padding(.horizontal)
            .padding(.top, 2)
            .frame(minHeight: 20)
            
            // Divider to separate keyboard from content
            Divider()
            
            // First row: 0-3
            HStack(spacing: 8) {
                ForEach(0...3, id: \.self) { number in
                    KeyButton(
                        key: "\(number)",
                        displayText: "\(number)",
                        color: colorForKey("\(number)"),
                        onTap: handleKeyTap,
                        isEnabled: isKeyValid("\(number)")
                    )
                }
            }
            
            // Second row: 4-7
            HStack(spacing: 8) {
                ForEach(4...7, id: \.self) { number in
                    KeyButton(
                        key: "\(number)",
                        displayText: "\(number)",
                        color: colorForKey("\(number)"),
                        onTap: handleKeyTap,
                        isEnabled: isKeyValid("\(number)")
                    )
                }
            }
            
            // Third row: 8-9, X, E (duodecimal specific)
            HStack(spacing: 8) {
                // Numbers 8-9
                ForEach(8...9, id: \.self) { number in
                    KeyButton(
                        key: "\(number)",
                        displayText: "\(number)",
                        color: colorForKey("\(number)"),
                        onTap: handleKeyTap,
                        isEnabled: isKeyValid("\(number)")
                    )
                }
                
                // Duodecimal specific keys
                KeyButton(
                    key: "X",
                    displayText: "X",
                    color: BaseTheme.duodecimal,
                    onTap: handleKeyTap,
                    isEnabled: isKeyValid("X")
                )
                
                KeyButton(
                    key: "E_DUO",
                    displayText: "E",
                    color: BaseTheme.duodecimal,
                    onTap: handleKeyTap,
                    isEnabled: isKeyValid("E_DUO")
                )
            }
            
            // Fourth row: Hexadecimal letters A-F
            HStack(spacing: 6) {
                // Hex letters A-D
                ForEach(["A", "B", "C", "D"], id: \.self) { letter in
                    KeyButton(
                        key: letter,
                        displayText: letter,
                        color: BaseTheme.hexadecimal,
                        onTap: handleKeyTap,
                        isEnabled: isKeyValid(letter)
                    )
                }
                
                // Hexadecimal E
                KeyButton(
                    key: "E_HEX",
                    displayText: "E",
                    color: BaseTheme.hexadecimal,
                    onTap: handleKeyTap,
                    isEnabled: isKeyValid("E_HEX")
                )
                
                // Hexadecimal F
                KeyButton(
                    key: "F",
                    displayText: "F",
                    color: BaseTheme.hexadecimal,
                    onTap: handleKeyTap,
                    isEnabled: isKeyValid("F")
                )
            }
            
            // Fifth row: Sign toggle, Decrement, Increment, and Backspace
            HStack(spacing: 8) {
                // Negative sign button (±)
                KeyButton(
                    key: "-",
                    displayText: "±",
                    color: Color.gray,
                    onTap: handleKeyTap,
                    isEnabled: focusedField != nil
                )
                
                // Decrement button (-)
                Button(action: {
                    // Add haptic feedback when decrement button is tapped
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    
                    onKeyTap("DECREMENT")
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 45)
                        .background(focusedField != nil ? Color.gray : Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(focusedField == nil)
                .accessibilityLabel("Decrease value")
                .accessibilityHint("Tap to decrease the current value by 1")
                .accessibilityAddTraits(.isButton)
                
                // Increment button (+)
                Button(action: {
                    // Add haptic feedback when increment button is tapped
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    
                    onKeyTap("INCREMENT")
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 45)
                        .background(focusedField != nil ? Color.gray : Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(focusedField == nil)
                .accessibilityLabel("Increase value")
                .accessibilityHint("Tap to increase the current value by 1")
                .accessibilityAddTraits(.isButton)
                
                // Backspace button
                Button(action: {
                    onKeyTap("⌫")
                    // Add haptic feedback when backspace is tapped
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 45)
                        .background(focusedField != nil ? Color.gray : Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(focusedField == nil)
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Backspace")
                .accessibilityHint("Tap to delete the last character")
                .accessibilityAddTraits(.isButton)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .background(Color(UIColor.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 2, y: -1)
    }
}

// Individual keyboard button
struct KeyButton: View {
    let key: String
    let displayText: String
    let color: Color
    let onTap: (String) -> Void
    var isEnabled: Bool = true
    
    var body: some View {
        Button(action: {
            onTap(key)
            // Add haptic feedback when button is tapped
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }) {
            Text(displayText)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 45)  // Reduced from 50 to 45
                .background(isEnabled ? color : color.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(!isEnabled)
        .accessibilityLabel("\(displayText) key")
        .accessibilityHint(isEnabled ? "Tap to enter \(displayText)" : "This key is not available in current mode")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    CustomKeyboard(onKeyTap: { _ in }, focusedField: .base10)
        .previewLayout(.sizeThatFits)
} 