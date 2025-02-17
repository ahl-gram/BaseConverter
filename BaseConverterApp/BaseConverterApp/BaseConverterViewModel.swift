import Foundation

@MainActor
class BaseConverterViewModel: ObservableObject {
    @Published var base2Input = ""
    @Published var base10Input = ""
    @Published var base12Input = ""
    @Published var base16Input = ""
    @Published var errorMessage: String?
    
    // Input validation flags
    @Published var isBase2Valid = true
    @Published var isBase10Valid = true
    @Published var isBase12Valid = true
    @Published var isBase16Valid = true
    
    // Validation patterns
    private let base2Pattern = "^[01]*$"
    private let base10Pattern = "^[0-9]*$"
    private let base12Pattern = "^[0-9AB]*$"
    private let base16Pattern = "^[0-9A-F]*$"
    
    func validateInput(_ input: String, for base: Int) -> Bool {
        let pattern: String
        switch base {
        case 2:
            pattern = base2Pattern
        case 10:
            pattern = base10Pattern
        case 12:
            pattern = base12Pattern
        case 16:
            pattern = base16Pattern
        default:
            return false
        }
        
        return input.isEmpty || input.range(of: pattern, options: .regularExpression) != nil
    }
    
    func updateValidation() {
        isBase2Valid = validateInput(base2Input, for: 2)
        isBase10Valid = validateInput(base10Input, for: 10)
        isBase12Valid = validateInput(base12Input, for: 12)
        isBase16Valid = validateInput(base16Input, for: 16)
    }
    
    func reset() {
        base2Input = ""
        base10Input = ""
        base12Input = ""
        base16Input = ""
        errorMessage = nil
        updateValidation()
    }
} 