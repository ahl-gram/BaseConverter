import XCTest
import SwiftUI
@testable import BaseConverterApp

@MainActor
final class ContentViewTests: XCTestCase {
    // Test the increment and decrement logic directly without ContentView
    var viewModel: BaseConverterViewModel!
    
    override func setUp() async throws {
        // Create a ViewModel directly for testing
        viewModel = BaseConverterViewModel()
        
        // Set default values for testing
        viewModel.base10Input = "5"
        // Let the conversions happen
        await Task.yield()
    }

    func testIncrement() async {
        // Test incrementing with base10 input
        viewModel.incrementValue()
        await Task.yield() // Allow async updates to complete
        
        // Check that the value was incremented
        XCTAssertEqual(viewModel.base10Input, "6")
        XCTAssertEqual(viewModel.base8Input, "6")
        // Check that other bases were updated correctly
        XCTAssertEqual(viewModel.base2Input, "110")
        XCTAssertEqual(viewModel.base8Input, "6")
        XCTAssertEqual(viewModel.base12Input, "6")
        XCTAssertEqual(viewModel.base16Input, "6")
    }
    
    func testDecrement() async {
        // Test decrementing with base10 input
        viewModel.decrementValue()
        await Task.yield() // Allow async updates to complete
        
        // Check that the value was decremented
        XCTAssertEqual(viewModel.base10Input, "4")
        XCTAssertEqual(viewModel.base8Input, "4")
        // Check that other bases were updated correctly
        XCTAssertEqual(viewModel.base2Input, "100")
        XCTAssertEqual(viewModel.base8Input, "4")
        XCTAssertEqual(viewModel.base12Input, "4")
        XCTAssertEqual(viewModel.base8Input, "4")
        XCTAssertEqual(viewModel.base16Input, "4")
    }
    
    func testIncrementFromZero() async {
        // Set value to zero
        viewModel.base10Input = "0"
        await Task.yield()
        
        // Increment
        viewModel.incrementValue()
        await Task.yield()
        
        // Check that value changed from 0 to 1
        XCTAssertEqual(viewModel.base10Input, "1")
        XCTAssertEqual(viewModel.base2Input, "1")
        XCTAssertEqual(viewModel.base8Input, "1")
        XCTAssertEqual(viewModel.base12Input, "1")
        XCTAssertEqual(viewModel.base16Input, "1")
    }
    
    func testDecrementFromZero() async {
        // Set value to zero
        viewModel.base10Input = "0"
        await Task.yield()
        
        // Decrement
        viewModel.decrementValue()
        await Task.yield()
        
        // Check that value changed from 0 to -1
        XCTAssertEqual(viewModel.base10Input, "-1")
        XCTAssertEqual(viewModel.base2Input, "-1")
        XCTAssertEqual(viewModel.base8Input, "-1")
        XCTAssertEqual(viewModel.base12Input, "-1")
        XCTAssertEqual(viewModel.base16Input, "-1")
    }
    
    func testIncrementNegativeNumber() async {
        // Set a negative value
        viewModel.base10Input = "-5"
        await Task.yield()
        
        // Increment
        viewModel.incrementValue()
        await Task.yield()
        
        // Check that value changed from -5 to -4
        XCTAssertEqual(viewModel.base10Input, "-4")
        XCTAssertEqual(viewModel.base2Input, "-100")
        XCTAssertEqual(viewModel.base8Input, "-4")
        XCTAssertEqual(viewModel.base12Input, "-4")
        XCTAssertEqual(viewModel.base16Input, "-4")
    }
    
    func testDecrementNegativeNumber() async {
        // Set a negative value
        viewModel.base10Input = "-5"
        await Task.yield()
        
        // Decrement
        viewModel.decrementValue()
        await Task.yield()
        
        // Check that value changed from -5 to -6
        XCTAssertEqual(viewModel.base10Input, "-6")
        XCTAssertEqual(viewModel.base2Input, "-110")
        XCTAssertEqual(viewModel.base8Input, "-6")
        XCTAssertEqual(viewModel.base12Input, "-6")
        XCTAssertEqual(viewModel.base16Input, "-6")
    }
    
    func testIncrementEmptyInput() async {
        // Set empty input
        viewModel.base10Input = ""
        await Task.yield()
        
        // Increment should set the value to "1"
        viewModel.incrementValue()
        await Task.yield()
        
        // Check that values are updated to 1
        XCTAssertEqual(viewModel.base10Input, "1")
        XCTAssertEqual(viewModel.base2Input, "1")
        XCTAssertEqual(viewModel.base8Input, "1")
        XCTAssertEqual(viewModel.base12Input, "1")
        XCTAssertEqual(viewModel.base16Input, "1")
    }
    
    func testDecrementEmptyInput() async {
        // Set empty input
        viewModel.base10Input = ""
        await Task.yield()
        
        // Decrement should set the value to "-1"
        viewModel.decrementValue()
        await Task.yield()
        
        // Check that values are updated to -1
        XCTAssertEqual(viewModel.base10Input, "-1")
        XCTAssertEqual(viewModel.base2Input, "-1")
        XCTAssertEqual(viewModel.base8Input, "-1")
        XCTAssertEqual(viewModel.base12Input, "-1")
        XCTAssertEqual(viewModel.base16Input, "-1")
    }
    
    func testIncrementInvalidInput() async {
        // Set invalid input
        viewModel.base10Input = "ABC"
        await Task.yield()
        
        // Increment should do nothing with invalid input
        viewModel.incrementValue()
        await Task.yield()
        
        // Check that invalid value remains unchanged
        XCTAssertEqual(viewModel.base10Input, "ABC")
    }
    
    func testDecrementInvalidInput() async {
        // Set invalid input
        viewModel.base10Input = "ABC"
        await Task.yield()
        
        // Decrement should do nothing with invalid input
        viewModel.decrementValue()
        await Task.yield()
        
        // Check that invalid value remains unchanged
        XCTAssertEqual(viewModel.base10Input, "ABC")
    }
    
    // Test incrementing at the maximum value
    func testIncrementAtMaxValue() async {
        // Set value to max
        viewModel.base10Input = String(viewModel.maxValue)
        await Task.yield()
        
        // Increment
        viewModel.incrementValue()
        await Task.yield()
        
        // Check that value did not change and error message is set
        XCTAssertEqual(viewModel.base10Input, String(viewModel.maxValue))
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, BaseConverterError.resultOutOfRange(min: viewModel.minValue, max: viewModel.maxValue).message)
    }
    
    // Test decrementing at the minimum value
    func testDecrementAtMinValue() async {
        // Set value to min
        viewModel.base10Input = String(viewModel.minValue)
        await Task.yield()
        
        // Decrement
        viewModel.decrementValue()
        await Task.yield()
        
        // Check that value did not change and error message is set
        XCTAssertEqual(viewModel.base10Input, String(viewModel.minValue))
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, BaseConverterError.resultOutOfRange(min: viewModel.minValue, max: viewModel.maxValue).message)
    }
} 
