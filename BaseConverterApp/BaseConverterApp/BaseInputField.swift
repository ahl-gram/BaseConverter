import SwiftUI

/// A styled input field for displaying and editing numeric values in different bases
struct BaseInputField: View {
    let title: String
    @Binding var text: String
    let isValid: Bool
    let field: BaseField
    let viewModel: BaseConverterViewModel
    @FocusState var focusedField: BaseField?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(field.themeColor)
                .dynamicTypeSize(.small ... .xxxLarge) // Enable Dynamic Type
            
            // Use our custom CustomKeyboardTextField
            CustomKeyboardTextField(
                text: $text,
                placeholder: text.isEmpty ? "\(field.description)" : ""
            )
            .modifier(BaseInputStyle(isValid: isValid, themeColor: field.themeColor))
            .dynamicTypeSize(.small ... .xxxLarge) // Enable Dynamic Type for input field
            .focused($focusedField, equals: field)
            .onChange(of: text) { _ in
                viewModel.updateValidation()
            }
            .accessibilityLabel("\(field.description) input")
            .accessibilityValue(text.isEmpty ? "Empty" : text)
            .accessibilityHint("Tap to enter \(field.description) value. Valid characters are \(field.displayValidCharacters)")
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true) // Only allow vertical growth
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true) // Also constrain the parent
    }
}

/// A style modifier for input fields
struct BaseInputStyle: ViewModifier {
    let isValid: Bool
    let themeColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: isValid ? themeColor.opacity(0.3) : .red.opacity(0.3), radius: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isValid ? themeColor : Color.red, lineWidth: 2)
            )
            .frame(maxWidth: .infinity) // Enforce maximum width constraint
            .fixedSize(horizontal: false, vertical: true) // Only allow vertical growth
            .clipShape(RoundedRectangle(cornerRadius: 10))  // Ensure content is clipped to the container
    }
}

/// Color theme for different bases
struct BaseTheme {
    static let binary = Color.blue       // Binary feels technical, blue is appropriate
    static let decimal = Color.green     // Decimal is standard/natural, green works well
    static let duodecimal = Color.purple // Duodecimal is special/unique, purple fits
    static let hexadecimal = Color.orange // Hex is often used in web/design, orange is creative
}

/// Enum representing the different number base fields
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
