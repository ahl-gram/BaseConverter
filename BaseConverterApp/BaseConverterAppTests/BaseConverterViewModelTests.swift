import XCTest
@testable import BaseConverterApp

@MainActor
final class BaseConverterViewModelTests: XCTestCase {
    var viewModel: BaseConverterViewModel!
    
    override func setUp() async throws {
        viewModel = BaseConverterViewModel()
    }
    
    func testInputValidation() {
        // Test Base 2 validation
        viewModel.base2Input = "1010"
        XCTAssertTrue(viewModel.isBase2Valid)
        viewModel.base2Input = "102"
        XCTAssertFalse(viewModel.isBase2Valid)
        
        // Test Base 10 validation
        viewModel.base10Input = "123"
        XCTAssertTrue(viewModel.isBase10Valid)
        viewModel.base10Input = "12A"
        XCTAssertFalse(viewModel.isBase10Valid)
        
        // Test Base 12 validation
        viewModel.base12Input = "AB9"
        XCTAssertTrue(viewModel.isBase12Valid)
        viewModel.base12Input = "ABC"
        XCTAssertFalse(viewModel.isBase12Valid)
        
        // Test Base 16 validation
        viewModel.base16Input = "FF"
        XCTAssertTrue(viewModel.isBase16Valid)
        viewModel.base16Input = "FG"
        XCTAssertFalse(viewModel.isBase16Valid)
    }
    
    func testNegativeNumberValidation() {
        // Test negative numbers in different bases
        viewModel.base2Input = "-1010"
        XCTAssertTrue(viewModel.isBase2Valid)
        
        viewModel.base10Input = "-123"
        XCTAssertTrue(viewModel.isBase10Valid)
        
        viewModel.base12Input = "-AB9"
        XCTAssertTrue(viewModel.isBase12Valid)
        
        viewModel.base16Input = "-FF"
        XCTAssertTrue(viewModel.isBase16Valid)
    }
    
    func testRangeValidation() async {
        // Test number within range
        viewModel.base10Input = "1000000000"
        await Task.yield()
        XCTAssertNil(viewModel.errorMessage)
        
        // Test number above range
        viewModel.base10Input = "1000000001"
        await Task.yield()
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Number must be between -1000000000 and 1000000000")
        
        // Test negative number within range
        viewModel.base10Input = "-1000000000"
        await Task.yield()
        XCTAssertNil(viewModel.errorMessage)
        
        // Test negative number below range
        viewModel.base10Input = "-1000000001"
        await Task.yield()
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testLeadingZeros() async {
        // Test leading zeros are removed
        viewModel.base10Input = "00123"
        await Task.yield()
        XCTAssertEqual(viewModel.base10Input, "123")
        
        // Test negative number with leading zeros
        viewModel.base10Input = "-00123"
        await Task.yield()
        XCTAssertEqual(viewModel.base10Input, "-123")
        
        // Test single zero is preserved
        viewModel.base10Input = "0"
        await Task.yield()
        XCTAssertEqual(viewModel.base10Input, "0")
    }
    
    func testValidationMessages() async {
        // Test positive number
        viewModel.base10Input = "123"
        await Task.yield()
        XCTAssertEqual(viewModel.validationMessage, "Positive integer")
        
        // Test negative number
        viewModel.base10Input = "-123"
        await Task.yield()
        XCTAssertEqual(viewModel.validationMessage, "Negative integer")
        
        // Test zero
        viewModel.base10Input = "0"
        await Task.yield()
        XCTAssertEqual(viewModel.validationMessage, "Zero")
        
        // Test invalid input clears validation message
        viewModel.base10Input = "ABC"
        await Task.yield()
        XCTAssertNil(viewModel.validationMessage)
    }
    
    func testBase2InputConversion() async {
        viewModel.base2Input = "1010"
        await Task.yield()
        
        XCTAssertEqual(viewModel.base10Input, "10")
        XCTAssertEqual(viewModel.base12Input, "A")
        XCTAssertEqual(viewModel.base16Input, "A")
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testBase10InputConversion() async {
        viewModel.base10Input = "15"
        await Task.yield()
        
        XCTAssertEqual(viewModel.base2Input, "1111")
        XCTAssertEqual(viewModel.base12Input, "13")
        XCTAssertEqual(viewModel.base16Input, "F")
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testBase12InputConversion() async {
        viewModel.base12Input = "A"
        await Task.yield()
        
        XCTAssertEqual(viewModel.base2Input, "1010")
        XCTAssertEqual(viewModel.base10Input, "10")
        XCTAssertEqual(viewModel.base16Input, "A")
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testBase16InputConversion() async {
        viewModel.base16Input = "FF"
        await Task.yield()
        
        XCTAssertEqual(viewModel.base2Input, "11111111")
        XCTAssertEqual(viewModel.base10Input, "255")
        XCTAssertEqual(viewModel.base12Input, "193")
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testInvalidInputHandling() async {
        viewModel.base2Input = "102"
        await Task.yield()
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isBase2Valid)
    }
    
    func testReset() {
        viewModel.base10Input = "15"
        viewModel.reset()
        
        XCTAssertEqual(viewModel.base2Input, "")
        XCTAssertEqual(viewModel.base10Input, "")
        XCTAssertEqual(viewModel.base12Input, "")
        XCTAssertEqual(viewModel.base16Input, "")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.validationMessage)
    }
    
    func testEmptyInput() async {
        viewModel.base10Input = "15"
        await Task.yield()
        
        viewModel.base10Input = ""
        await Task.yield()
        
        XCTAssertEqual(viewModel.base2Input, "")
        XCTAssertEqual(viewModel.base12Input, "")
        XCTAssertEqual(viewModel.base16Input, "")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.validationMessage)
    }
    
    func testAddition() async {
        // Test addition in base 10
        viewModel.base10Input = "15"
        viewModel.startOperation(.add, from: 10)
        viewModel.secondOperand = "7"
        viewModel.performOperation()
        XCTAssertEqual(viewModel.operationResult, "22")
        
        // Test addition in base 2
        viewModel.base2Input = "1010"  // 10 in decimal
        viewModel.startOperation(.add, from: 2)
        viewModel.secondOperand = "101"  // 5 in decimal
        viewModel.performOperation()
        XCTAssertEqual(viewModel.operationResult, "1111")  // 15 in decimal
        
        // Test addition with negative numbers
        viewModel.base10Input = "-15"
        viewModel.startOperation(.add, from: 10)
        viewModel.secondOperand = "7"
        viewModel.performOperation()
        XCTAssertEqual(viewModel.operationResult, "-8")
    }
    
    func testSubtraction() async {
        // Test subtraction in base 10
        viewModel.base10Input = "15"
        viewModel.startOperation(.subtract, from: 10)
        viewModel.secondOperand = "7"
        viewModel.performOperation()
        XCTAssertEqual(viewModel.operationResult, "8")
        
        // Test subtraction in base 16
        viewModel.base16Input = "FF"  // 255 in decimal
        viewModel.startOperation(.subtract, from: 16)
        viewModel.secondOperand = "F"  // 15 in decimal
        viewModel.performOperation()
        XCTAssertEqual(viewModel.operationResult, "F0")  // 240 in decimal
        
        // Test subtraction with negative result
        viewModel.base10Input = "7"
        viewModel.startOperation(.subtract, from: 10)
        viewModel.secondOperand = "15"
        viewModel.performOperation()
        XCTAssertEqual(viewModel.operationResult, "-8")
    }
    
    func testMultiplication() async {
        // Test multiplication in base 10
        viewModel.base10Input = "15"
        viewModel.startOperation(.multiply, from: 10)
        viewModel.secondOperand = "7"
        viewModel.performOperation()
        XCTAssertEqual(viewModel.operationResult, "105")
        
        // Test multiplication in base 12
        viewModel.base12Input = "A"  // 10 in decimal
        viewModel.startOperation(.multiply, from: 12)
        viewModel.secondOperand = "3"
        viewModel.performOperation()
        XCTAssertEqual(viewModel.operationResult, "26")  // 30 in decimal
        
        // Test multiplication with negative numbers
        viewModel.base10Input = "-15"
        viewModel.startOperation(.multiply, from: 10)
        viewModel.secondOperand = "7"
        viewModel.performOperation()
        XCTAssertEqual(viewModel.operationResult, "-105")
    }
    
    func testDivision() async {
        // Test division in base 10
        viewModel.base10Input = "15"
        viewModel.startOperation(.divide, from: 10)
        viewModel.secondOperand = "3"
        viewModel.performOperation()
        XCTAssertEqual(viewModel.operationResult, "5")
        
        // Test division in base 2
        viewModel.base2Input = "1010"  // 10 in decimal
        viewModel.startOperation(.divide, from: 2)
        viewModel.secondOperand = "10"  // 2 in decimal
        viewModel.performOperation()
        XCTAssertEqual(viewModel.operationResult, "101")  // 5 in decimal
        
        // Test division with negative numbers
        viewModel.base10Input = "-15"
        viewModel.startOperation(.divide, from: 10)
        viewModel.secondOperand = "3"
        viewModel.performOperation()
        XCTAssertEqual(viewModel.operationResult, "-5")
    }
    
    func testDivisionByZero() async {
        viewModel.base10Input = "15"
        viewModel.startOperation(.divide, from: 10)
        viewModel.secondOperand = "0"
        viewModel.performOperation()
        XCTAssertEqual(viewModel.errorMessage, "Cannot divide by zero")
        XCTAssertNil(viewModel.operationResult)
    }
    
    func testOperationOverflow() async {
        // Test addition overflow
        viewModel.base10Input = "1000000000"
        viewModel.startOperation(.add, from: 10)
        viewModel.secondOperand = "1"
        viewModel.performOperation()
        XCTAssertEqual(viewModel.errorMessage, "Result is too large")
        
        // Test multiplication overflow
        viewModel.base10Input = "1000000000"
        viewModel.startOperation(.multiply, from: 10)
        viewModel.secondOperand = "2"
        viewModel.performOperation()
        XCTAssertEqual(viewModel.errorMessage, "Result is too large")
    }
    
    func testOperationReset() async {
        viewModel.base10Input = "15"
        viewModel.startOperation(.add, from: 10)
        viewModel.secondOperand = "7"
        viewModel.performOperation()
        XCTAssertNotNil(viewModel.operationResult)
        
        viewModel.reset()
        XCTAssertNil(viewModel.operationResult)
        XCTAssertEqual(viewModel.secondOperand, "")
        XCTAssertEqual(viewModel.base10Input, "")
    }
    
    func testAdditionUpdatesAllBases() async {
        // Perform addition in base 10
        viewModel.base10Input = "15"
        viewModel.startOperation(.add, from: 10)
        viewModel.secondOperand = "7"
        viewModel.performOperation()
        
        // Check that all bases are updated with the result (22)
        XCTAssertEqual(viewModel.base2Input, "10110")     // 22 in binary
        XCTAssertEqual(viewModel.base10Input, "22")       // 22 in decimal
        XCTAssertEqual(viewModel.base12Input, "1A")       // 22 in duodecimal
        XCTAssertEqual(viewModel.base16Input, "16")       // 22 in hexadecimal
        XCTAssertEqual(viewModel.operationResult, "22")   // Result in original base (10)
        XCTAssertEqual(viewModel.validationMessage, "Positive integer")
    }
} 