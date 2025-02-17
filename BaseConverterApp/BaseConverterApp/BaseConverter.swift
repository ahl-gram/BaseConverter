import Foundation

enum BaseConverterError: Error {
    case invalidInput
    case unsupportedBase
    case overflow
}

struct BaseConverter {
    // Convert string in given base to decimal integer
    static func toDecimal(string: String, from base: Int) throws -> Int {
        guard !string.isEmpty else { return 0 }
        
        let isNegative = string.hasPrefix("-")
        let absString = isNegative ? String(string.dropFirst()) : string
        
        var result = 0
        let digits = Array(absString.uppercased())
        
        for digit in digits {
            guard let value = digitToValue(digit) else {
                throw BaseConverterError.invalidInput
            }
            guard value < base else {
                throw BaseConverterError.invalidInput
            }
            
            // Check for overflow before multiplying
            guard result <= Int.max / base else {
                throw BaseConverterError.overflow
            }
            result *= base
            
            // Check for overflow before adding
            guard result <= Int.max - value else {
                throw BaseConverterError.overflow
            }
            result += value
        }
        
        return isNegative ? -result : result
    }
    
    // Convert decimal integer to string in target base
    static func fromDecimal(_ number: Int, to base: Int) throws -> String {
        guard base >= 2 && base <= 16 else {
            throw BaseConverterError.unsupportedBase
        }
        
        if number == 0 { return "0" }
        
        let isNegative = number < 0
        var absNumber = abs(number)
        var digits: [String] = []
        
        while absNumber > 0 {
            let remainder = absNumber % base
            digits.append(valueToDigit(remainder))
            absNumber /= base
        }
        
        let result = digits.reversed().joined()
        return isNegative ? "-\(result)" : result
    }
    
    // Convert between any supported bases
    static func convert(input: String, from: Int, to: Int) throws -> String {
        guard from >= 2 && from <= 16 && to >= 2 && to <= 16 else {
            throw BaseConverterError.unsupportedBase
        }
        
        let decimal = try toDecimal(string: input, from: from)
        return try fromDecimal(decimal, to: to)
    }
    
    // Helper function to convert a single digit to its decimal value
    private static func digitToValue(_ digit: Character) -> Int? {
        switch digit {
        case "0"..."9":
            return Int(String(digit))
        case "A":
            return 10
        case "B":
            return 11
        case "C":
            return 12
        case "D":
            return 13
        case "E":
            return 14
        case "F":
            return 15
        default:
            return nil
        }
    }
    
    // Helper function to convert a decimal value to a digit
    private static func valueToDigit(_ value: Int) -> String {
        if value < 10 {
            return String(value)
        } else {
            return String(Character(UnicodeScalar(55 + value)!))
        }
    }
} 