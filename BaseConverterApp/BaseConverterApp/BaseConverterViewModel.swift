import Foundation

@MainActor
class BaseConverterViewModel: ObservableObject {
    @Published var base2Input = "" {
        didSet {
            if oldValue != base2Input {
                handleInputChange(base2Input, from: 2)
            }
        }
    }
    
    @Published var base10Input = "" {
        didSet {
            if oldValue != base10Input {
                handleInputChange(base10Input, from: 10)
            }
        }
    }
    
    @Published var base12Input = "" {
        didSet {
            if oldValue != base12Input {
                handleInputChange(base12Input, from: 12)
            }
        }
    }
    
    @Published var base16Input = "" {
        didSet {
            if oldValue != base16Input {
                handleInputChange(base16Input, from: 16)
            }
        }
    }
    
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
    
    // Flag to prevent recursive updates
    private var isUpdating = false
    
    private func handleInputChange(_ input: String, from base: Int) {
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false }
        
        updateValidation()
        
        guard !input.isEmpty else {
            clearOtherInputs(except: base)
            errorMessage = nil
            return
        }
        
        do {
            // Convert to other bases
            if base != 2 {
                base2Input = try BaseConverter.convert(input: input, from: base, to: 2)
            }
            if base != 10 {
                base10Input = try BaseConverter.convert(input: input, from: base, to: 10)
            }
            if base != 12 {
                base12Input = try BaseConverter.convert(input: input, from: base, to: 12)
            }
            if base != 16 {
                base16Input = try BaseConverter.convert(input: input, from: base, to: 16)
            }
            errorMessage = nil
        } catch BaseConverterError.invalidInput {
            errorMessage = "Invalid input for base \(base)"
        } catch BaseConverterError.overflow {
            errorMessage = "Number is too large"
        } catch {
            errorMessage = "Conversion error"
        }
    }
    
    private func clearOtherInputs(except base: Int) {
        if base != 2 { base2Input = "" }
        if base != 10 { base10Input = "" }
        if base != 12 { base12Input = "" }
        if base != 16 { base16Input = "" }
    }
    
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