import SwiftUI

struct CustomKeyboard: View {
    // Callback function to handle keyboard input
    var onKeyTap: (String) -> Void
    // Currently focused field (if any)
    var focusedField: ContentView.BaseField?
    
    // Function to determine the color of each key based on what bases it's used in
    private func colorForKey(_ key: String) -> Color {
        switch key {
        case "0", "1":
            // Used in all bases, use binary color as most restrictive
            return BaseTheme.binary
        case "2", "3", "4", "5", "6", "7", "8", "9":
            // Used in base 10, 12, and 16
            return BaseTheme.decimal
        case "X", "E":
            // Used only in base 12
            return BaseTheme.duodecimal
        case "A", "B", "C", "D", "F":
            // Used only in base 16
            return BaseTheme.hexadecimal
        default:
            return .gray
        }
    }
    
    // Check if a key is valid for the currently focused field
    private func isKeyValid(_ key: String) -> Bool {
        guard let field = focusedField else {
            return false // No focused field, all keys are disabled
        }
        
        if key == "⌫" || key == "-" {
            return true // Backspace and negative are always valid
        }
        
        return field.validCharacters.contains(key)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Show current mode at the top of the keyboard
            if let field = focusedField {
                HStack {
                    Text("Current mode: \(field.description)")
                        .font(.caption)
                        .foregroundColor(field.themeColor)
                        .padding(.top, 4)
                    Spacer()
                }
                .padding(.horizontal)
            } else {
                HStack {
                    Text("Tap a field to begin entering values")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            // Divider to separate keyboard from content
            Divider()
            
            // First row: 0-9
            HStack(spacing: 6) {
                ForEach(0...9, id: \.self) { number in
                    KeyButton(
                        key: "\(number)",
                        color: colorForKey("\(number)"),
                        onTap: onKeyTap,
                        isEnabled: isKeyValid("\(number)")
                    )
                }
            }
            
            // Second row: Letters and special keys
            HStack(spacing: 6) {
                // Base 16 letters A-D
                ForEach(["A", "B", "C", "D"], id: \.self) { letter in
                    KeyButton(
                        key: letter,
                        color: BaseTheme.hexadecimal,
                        onTap: onKeyTap,
                        isEnabled: isKeyValid(letter)
                    )
                }
                
                // E key (used in both base 12 and 16, but use the duodecimal color as it's more specific)
                KeyButton(
                    key: "E",
                    color: BaseTheme.duodecimal,
                    onTap: onKeyTap,
                    isEnabled: isKeyValid("E")
                )
                
                // F key (base 16)
                KeyButton(
                    key: "F",
                    color: BaseTheme.hexadecimal,
                    onTap: onKeyTap,
                    isEnabled: isKeyValid("F")
                )
                
                // X key (base 12)
                KeyButton(
                    key: "X",
                    color: BaseTheme.duodecimal,
                    onTap: onKeyTap,
                    isEnabled: isKeyValid("X")
                )
                
                // Negative sign button
                KeyButton(
                    key: "-",
                    color: Color.gray,
                    onTap: onKeyTap,
                    isEnabled: focusedField != nil
                )
                
                // Backspace button
                Button(action: {
                    onKeyTap("⌫")
                }) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(focusedField != nil ? Color.gray : Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(focusedField == nil)
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
    let color: Color
    let onTap: (String) -> Void
    var isEnabled: Bool = true
    
    var body: some View {
        Button(action: {
            onTap(key)
        }) {
            Text(key)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(minWidth: 30, maxWidth: .infinity)
                .frame(height: 40)
                .background(isEnabled ? color : color.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    CustomKeyboard(onKeyTap: { _ in }, focusedField: .base10)
        .previewLayout(.sizeThatFits)
} 