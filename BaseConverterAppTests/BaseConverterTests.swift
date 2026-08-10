import XCTest
@testable import BaseConverterApp

final class BaseConverterTests: XCTestCase {
    func testDecimalToBase2() throws {
        XCTAssertEqual(try BaseConverter.convert(input: "10", from: 10, to: 2), "1010")
        XCTAssertEqual(try BaseConverter.convert(input: "15", from: 10, to: 2), "1111")
        XCTAssertEqual(try BaseConverter.convert(input: "0", from: 10, to: 2), "0")
        XCTAssertEqual(try BaseConverter.convert(input: "-10", from: 10, to: 2), "-1010")
    }

    func testDecimalToBase8() throws {
        XCTAssertEqual(try BaseConverter.convert(input: "10", from: 10, to: 8), "12")
        XCTAssertEqual(try BaseConverter.convert(input: "15", from: 10, to: 8), "17")
        XCTAssertEqual(try BaseConverter.convert(input: "0", from: 10, to: 8), "0")
        XCTAssertEqual(try BaseConverter.convert(input: "-10", from: 10, to: 8), "-12")
    }
    
    func testDecimalToBase12() throws {
        XCTAssertEqual(try BaseConverter.convert(input: "10", from: 10, to: 12), "X")
        XCTAssertEqual(try BaseConverter.convert(input: "11", from: 10, to: 12), "E")
        XCTAssertEqual(try BaseConverter.convert(input: "12", from: 10, to: 12), "10")
        XCTAssertEqual(try BaseConverter.convert(input: "-12", from: 10, to: 12), "-10")
    }
    
    func testDecimalToBase16() throws {
        XCTAssertEqual(try BaseConverter.convert(input: "15", from: 10, to: 16), "F")
        XCTAssertEqual(try BaseConverter.convert(input: "255", from: 10, to: 16), "FF")
        XCTAssertEqual(try BaseConverter.convert(input: "0", from: 10, to: 16), "0")
        XCTAssertEqual(try BaseConverter.convert(input: "-255", from: 10, to: 16), "-FF")
    }
    
    func testBase2ToDecimal() throws {
        XCTAssertEqual(try BaseConverter.convert(input: "1010", from: 2, to: 10), "10")
        XCTAssertEqual(try BaseConverter.convert(input: "1111", from: 2, to: 10), "15")
        XCTAssertEqual(try BaseConverter.convert(input: "0", from: 2, to: 10), "0")
        XCTAssertEqual(try BaseConverter.convert(input: "-1010", from: 2, to: 10), "-10")
    }

    func testBase8ToDecimal() throws {
        XCTAssertEqual(try BaseConverter.convert(input: "12", from: 8, to: 10), "10")
        XCTAssertEqual(try BaseConverter.convert(input: "17", from: 8, to: 10), "15")
        XCTAssertEqual(try BaseConverter.convert(input: "0", from: 8, to: 10), "0")
        XCTAssertEqual(try BaseConverter.convert(input: "-12", from: 8, to: 10), "-10")
    }
    
    func testBase12ToDecimal() throws {
        XCTAssertEqual(try BaseConverter.convert(input: "X", from: 12, to: 10), "10")
        XCTAssertEqual(try BaseConverter.convert(input: "E", from: 12, to: 10), "11")
        XCTAssertEqual(try BaseConverter.convert(input: "10", from: 12, to: 10), "12")
        XCTAssertEqual(try BaseConverter.convert(input: "-10", from: 12, to: 10), "-12")
    }
    
    func testBase16ToDecimal() throws {
        XCTAssertEqual(try BaseConverter.convert(input: "F", from: 16, to: 10), "15")
        XCTAssertEqual(try BaseConverter.convert(input: "FF", from: 16, to: 10), "255")
        XCTAssertEqual(try BaseConverter.convert(input: "0", from: 16, to: 10), "0")
        XCTAssertEqual(try BaseConverter.convert(input: "-FF", from: 16, to: 10), "-255")
    }
    
    func testInvalidInput() throws {
        // Test invalid digits for each base
        var error = try? BaseConverter.convert(input: "2", from: 2, to: 10)
        XCTAssertNil(error)
        
        do {
            _ = try BaseConverter.convert(input: "G", from: 16, to: 10)
            XCTFail("Expected error for invalid hex digit")
        } catch BaseConverterError.invalidDigitForBase(let digit, let base) {
            XCTAssertEqual(digit, "G")
            XCTAssertEqual(base, 16)
        }
        
        do {
            _ = try BaseConverter.convert(input: "A", from: 12, to: 10)
            XCTFail("Expected error for invalid base 12 digit")
        } catch BaseConverterError.invalidDigitForBase(let digit, let base) {
            XCTAssertEqual(digit, "A")
            XCTAssertEqual(base, 12)
        }

        do {
            _ = try BaseConverter.convert(input: "8", from: 8, to: 10)
            XCTFail("Expected error for invalid base 8 digit")
        } catch BaseConverterError.invalidDigitForBase(let digit, let base) {
            XCTAssertEqual(digit, "8")
            XCTAssertEqual(base, 8)
        }
    }
    
    func testUnsupportedBase() throws {
        do {
            _ = try BaseConverter.convert(input: "10", from: 1, to: 10)
            XCTFail("Expected error for base 1")
        } catch BaseConverterError.unsupportedBase {
            // Expected error
        }
        
        do {
            _ = try BaseConverter.convert(input: "10", from: 10, to: 17)
            XCTFail("Expected error for base 17")
        } catch BaseConverterError.unsupportedBase {
            // Expected error
        }
    }
    
    func testEmptyInput() throws {
        do {
            _ = try BaseConverter.toDecimal(string: "", from: 10)
            XCTFail("Expected error for empty input")
        } catch BaseConverterError.emptyInput {
            // Expected error
        }
        
        do {
            _ = try BaseConverter.toDecimal(string: "-", from: 10)
            XCTFail("Expected error for just negative sign")
        } catch BaseConverterError.invalidInput {
            // Expected error
        }
    }
    
    func testOverflow() throws {
        // Test with a very large number that should cause overflow
        let largeBase2 = String(repeating: "1", count: 64)
        XCTAssertThrowsError(try BaseConverter.convert(input: largeBase2, from: 2, to: 10))
    }
    
    func testErrorMessages() {
        // Test error messages
        XCTAssertEqual(BaseConverterError.invalidInput.message, "Invalid input format")
        XCTAssertEqual(BaseConverterError.unsupportedBase.message, "Base must be between 2 and 16")
        XCTAssertEqual(BaseConverterError.overflow.message, "Result is too large")
        XCTAssertEqual(BaseConverterError.divisionByZero.message, "Cannot divide by zero")
        XCTAssertEqual(BaseConverterError.emptyInput.message, "Input cannot be empty")
        
        let invalidDigitError = BaseConverterError.invalidDigitForBase(digit: "G", base: 16)
        XCTAssertEqual(invalidDigitError.message, "Invalid digit 'G' for base 16")
        
        let rangeError = BaseConverterError.resultOutOfRange(min: -100, max: 100)
        XCTAssertEqual(rangeError.message, "Result must be between -100 and 100")
    }
} 