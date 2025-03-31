import Foundation
import Combine

class BaseConverterViewModel: ObservableObject {
    // Input properties
    @Published var base2Input = "" {
        didSet { 
            validateSpecificInput(base2Input, pattern: base2Pattern, setter: { self.isBase2Valid = $0 })
            cleanInputIfNeeded(base2Input, base: 2)
        }
    }
    @Published var base10Input = "" {
        didSet { 
            validateSpecificInput(base10Input, pattern: base10Pattern, setter: { self.isBase10Valid = $0 })
            cleanInputIfNeeded(base10Input, base: 10)
        }
    }
    @Published var base12Input = "" {
        didSet { 
            validateSpecificInput(base12Input, pattern: base12Pattern, setter: { self.isBase12Valid = $0 })
            cleanInputIfNeeded(base12Input, base: 12)
        }
    }
    @Published var base16Input = "" {
        didSet { 
            validateSpecificInput(base16Input, pattern: base16Pattern, setter: { self.isBase16Valid = $0 })
            cleanInputIfNeeded(base16Input, base: 16)
        }
    }
    
    // Validation properties
    @Published var isBase2Valid = true
    @Published var isBase10Valid = true
    @Published var isBase12Valid = true
    @Published var isBase16Valid = true
    
    // Message properties
    @Published var errorMessage: String?
    @Published var validationMessage: String?
    
    // Range constraints
    let minValue = -1_000_000_000
    let maxValue = 1_000_000_000
    
    // Validation patterns
    private let base2Pattern = "^-?[01]+$"
    private let base10Pattern = "^-?[0-9]+$"
    private let base12Pattern = "^-?[0-9XE]+$"
    private let base16Pattern = "^-?[0-9A-F]+$"
    
    // Flag to prevent recursive updates
    private var isUpdating = false
    
    // Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // Maximum display length for base inputs
    private let maxDisplayLength = 30
    
    init() {
        // Set up subscriptions for each input field
        $base2Input
            .removeDuplicates()
            .sink { [weak self] input in
                self?.handleInputChange(input, from: 2)
            }
            .store(in: &cancellables)
        
        $base10Input
            .removeDuplicates()
            .sink { [weak self] input in
                self?.handleInputChange(input, from: 10)
            }
            .store(in: &cancellables)
        
        $base12Input
            .removeDuplicates()
            .sink { [weak self] input in
                self?.handleInputChange(input, from: 12)
            }
            .store(in: &cancellables)
        
        $base16Input
            .removeDuplicates()
            .sink { [weak self] input in
                self?.handleInputChange(input, from: 16)
            }
            .store(in: &cancellables)
    }
    
    func updateValidation() {
        isBase2Valid = validateInput(base2Input, pattern: base2Pattern)
        isBase10Valid = validateInput(base10Input, pattern: base10Pattern)
        isBase12Valid = validateInput(base12Input, pattern: base12Pattern)
        isBase16Valid = validateInput(base16Input, pattern: base16Pattern)
    }
    
    private func validateInput(_ input: String, pattern: String) -> Bool {
        if input.isEmpty { return true }
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: input.utf16.count)
        return regex?.firstMatch(in: input, options: [], range: range) != nil
    }
    
    private func handleInputChange(_ input: String, from base: Int) {
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false }
        
        updateValidation()
        
        guard !input.isEmpty else {
            clearOtherInputs(except: base)
            errorMessage = nil
            validationMessage = nil
            return
        }
        
        // Remove leading zeros while preserving negative sign
        let cleanedInput = cleanInput(input)
        
        // If the input was cleaned, update it and then continue with conversion
        if cleanedInput != input {
            switch base {
            case 2: base2Input = cleanedInput
            case 10: base10Input = cleanedInput
            case 12: base12Input = cleanedInput
            case 16: base16Input = cleanedInput
            default: break
            }
            
            // Continue with the cleaned input
            // But exit the current function to avoid double processing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.handleInputChange(cleanedInput, from: base)
            }
            return
        }
        
        do {
            // First convert to decimal to check range
            let decimal = try BaseConverter.toDecimal(string: input, from: base)
            
            // Validate range
            guard decimal >= minValue && decimal <= maxValue else {
                throw BaseConverterError.resultOutOfRange(min: minValue, max: maxValue)
            }
            
            // Convert to other bases
            if base != 2 {
                let result = try BaseConverter.convert(input: input, from: base, to: 2)
                base2Input = result
            }
            if base != 10 {
                let result = try BaseConverter.convert(input: input, from: base, to: 10)
                base10Input = result
            }
            if base != 12 {
                let result = try BaseConverter.convert(input: input, from: base, to: 12)
                base12Input = result
            }
            if base != 16 {
                let result = try BaseConverter.convert(input: input, from: base, to: 16)
                base16Input = result
            }
            
            errorMessage = nil
            updateValidationMessage(for: decimal)
            
        } catch let error as BaseConverterError {
            errorMessage = error.message
            validationMessage = nil
        } catch {
            errorMessage = "Conversion error"
            validationMessage = nil
        }
    }
    
    private func clearOtherInputs(except base: Int) {
        if base != 2 { base2Input = "" }
        if base != 10 { base10Input = "" }
        if base != 12 { base12Input = "" }
        if base != 16 { base16Input = "" }
    }
    
    private func cleanInput(_ input: String) -> String {
        // Handle negative numbers
        if input.hasPrefix("-") {
            // For negative numbers, keep the negative sign and remove leading zeros
            let withoutSign = String(input.dropFirst())
            if withoutSign.isEmpty { return "-" }
            
            // Remove leading zeros
            let cleanedWithoutSign = withoutSign.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
            return cleanedWithoutSign.isEmpty ? "0" : "-\(cleanedWithoutSign)"
        } else {
            // For positive numbers, just remove leading zeros
            let cleaned = input.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
            return cleaned.isEmpty ? "0" : cleaned
        }
    }
    
    func updateValidationMessage(for value: Int) {
        if value == 0 {
            validationMessage = "Zero"
        } else if value > 0 {
            validationMessage = "Positive integer"
        } else {
            validationMessage = "Negative integer"
        }
    }
    
    func reset() {
        base2Input = ""
        base10Input = ""
        base12Input = ""
        base16Input = ""
        errorMessage = nil
        validationMessage = nil
    }
    
    private func validateSpecificInput(_ input: String, pattern: String, setter: (Bool) -> Void) {
        if input.isEmpty {
            setter(true)
            return
        }
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: input.utf16.count)
        setter(regex?.firstMatch(in: input, options: [], range: range) != nil)
    }
    
    // Helper method to clean input if needed
    private func cleanInputIfNeeded(_ input: String, base: Int) {
        if input.isEmpty { return }
        let cleaned = cleanInput(input)
        if cleaned != input {
            // Using DispatchQueue to avoid infinite recursion with the didSet
            DispatchQueue.main.async {
                switch base {
                case 2: self.base2Input = cleaned
                case 10: self.base10Input = cleaned
                case 12: self.base12Input = cleaned
                case 16: self.base16Input = cleaned
                default: break
                }
                
                // Trigger a conversion after cleaning to update other fields
                // Small delay to ensure the cleaned value is set first
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.handleInputChange(cleaned, from: base)
                }
            }
        }
    }
} 