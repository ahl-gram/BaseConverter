import Foundation

@MainActor
class BaseConverterViewModel: ObservableObject {
    // Constants for validation
    private let minValue = -1_000_000_000
    private let maxValue = 1_000_000_000
    
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
    @Published var validationMessage: String?
    @Published var operationResult: String?
    @Published var showingOperationSheet = false
    @Published var secondOperand = ""
    
    // Input validation flags
    @Published var isBase2Valid = true
    @Published var isBase10Valid = true
    @Published var isBase12Valid = true
    @Published var isBase16Valid = true
    
    // Operation state
    private var currentOperation: Operation?
    private var selectedBase: Int?
    
    enum Operation {
        case add, subtract, multiply, divide
        
        var symbol: String {
            switch self {
            case .add: return "+"
            case .subtract: return "-"
            case .multiply: return "×"
            case .divide: return "÷"
            }
        }
    }
    
    // Validation patterns
    private let base2Pattern = "^-?[01]+$"
    private let base10Pattern = "^-?[0-9]+$"
    private let base12Pattern = "^-?[0-9XE]+$"
    private let base16Pattern = "^-?[0-9A-F]+$"
    
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
            validationMessage = nil
            return
        }
        
        // Remove leading zeros while preserving negative sign
        let cleanedInput = cleanInput(input)
        
        // If the input was cleaned, update it
        if cleanedInput != input {
            switch base {
            case 2: base2Input = cleanedInput
            case 10: base10Input = cleanedInput
            case 12: base12Input = cleanedInput
            case 16: base16Input = cleanedInput
            default: break
            }
            return
        }
        
        do {
            // First convert to decimal to check range
            let decimal = try BaseConverter.toDecimal(string: input, from: base)
            
            // Validate range
            guard decimal >= minValue && decimal <= maxValue else {
                errorMessage = "Number must be between \(minValue) and \(maxValue)"
                return
            }
            
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
            updateValidationMessage(for: decimal)
        } catch BaseConverterError.invalidInput {
            errorMessage = "Invalid input for base \(base)"
            validationMessage = nil
        } catch BaseConverterError.overflow {
            errorMessage = "Number is too large"
            validationMessage = nil
        } catch {
            errorMessage = "Conversion error"
            validationMessage = nil
        }
    }
    
    func startOperation(_ operation: Operation, from base: Int) {
        currentOperation = operation
        selectedBase = base
        secondOperand = ""
        operationResult = nil
        errorMessage = nil
        showingOperationSheet = true
    }
    
    func performOperation() {
        guard let operation = currentOperation,
              let base = selectedBase else {
            return
        }
        
        do {
            // Get first operand from the current input
            let firstOperand: String
            switch base {
            case 2: firstOperand = base2Input
            case 10: firstOperand = base10Input
            case 12: firstOperand = base12Input
            case 16: firstOperand = base16Input
            default: return
            }
            
            // Convert both operands to decimal
            let decimal1 = try BaseConverter.toDecimal(string: firstOperand, from: base)
            let decimal2 = try BaseConverter.toDecimal(string: secondOperand, from: base)
            
            // Perform the operation
            let result: Int
            switch operation {
            case .add:
                guard !willOverflow(decimal1, plus: decimal2) else {
                    throw BaseConverterError.overflow
                }
                result = decimal1 + decimal2
                
            case .subtract:
                guard !willOverflow(decimal1, minus: decimal2) else {
                    throw BaseConverterError.overflow
                }
                result = decimal1 - decimal2
                
            case .multiply:
                guard !willOverflow(decimal1, times: decimal2) else {
                    throw BaseConverterError.overflow
                }
                result = decimal1 * decimal2
                
            case .divide:
                if decimal2 == 0 {
                    errorMessage = "Cannot divide by zero"
                    return
                }
                result = decimal1 / decimal2
            }
            
            // Validate result range
            guard result >= minValue && result <= maxValue else {
                throw BaseConverterError.overflow
            }
            
            // Convert result to all bases and update the input fields
            base2Input = try BaseConverter.fromDecimal(result, to: 2)
            base10Input = try BaseConverter.fromDecimal(result, to: 10)
            base12Input = try BaseConverter.fromDecimal(result, to: 12)
            base16Input = try BaseConverter.fromDecimal(result, to: 16)
            
            // Store the result in the original base
            operationResult = try BaseConverter.fromDecimal(result, to: base)
            errorMessage = nil
            updateValidationMessage(for: result)
            
        } catch BaseConverterError.invalidInput {
            errorMessage = "Invalid input for base \(base)"
        } catch BaseConverterError.overflow {
            errorMessage = "Result is too large"
        } catch {
            errorMessage = "Operation error"
        }
    }
    
    private func willOverflow(_ a: Int, plus b: Int) -> Bool {
        return (b > 0 && a > Int.max - b) || (b < 0 && a < Int.min - b)
    }
    
    private func willOverflow(_ a: Int, minus b: Int) -> Bool {
        return (b < 0 && a > Int.max + b) || (b > 0 && a < Int.min + b)
    }
    
    private func willOverflow(_ a: Int, times b: Int) -> Bool {
        if b == 0 { return false }
        let product = a * b
        return product / b != a
    }
    
    private func cleanInput(_ input: String) -> String {
        // Handle empty input
        guard !input.isEmpty else { return input }
        
        // Preserve negative sign
        let isNegative = input.hasPrefix("-")
        var cleanedInput = isNegative ? String(input.dropFirst()) : input
        
        // Remove leading zeros
        while cleanedInput.hasPrefix("0") && cleanedInput.count > 1 {
            cleanedInput = String(cleanedInput.dropFirst())
        }
        
        // Add back negative sign if needed
        return isNegative ? "-\(cleanedInput)" : cleanedInput
    }
    
    private func updateValidationMessage(for decimal: Int) {
        if decimal == 0 {
            validationMessage = "Zero"
        } else if decimal > 0 {
            validationMessage = "Positive integer"
        } else {
            validationMessage = "Negative integer"
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
        validationMessage = nil
        operationResult = nil
        secondOperand = ""
        currentOperation = nil
        selectedBase = nil
        updateValidation()
    }
} 