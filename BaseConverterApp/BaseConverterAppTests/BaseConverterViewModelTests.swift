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
} 