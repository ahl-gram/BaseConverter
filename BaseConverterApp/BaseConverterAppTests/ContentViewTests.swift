import XCTest
import SwiftUI
@testable import BaseConverterApp

@MainActor
final class ContentViewTests: XCTestCase {
    // We'll test the increment and decrement functions directly
    // since testing the UI interactions would require UI testing
    
    var viewModel: BaseConverterViewModel!
    var contentView: ContentView!
    
    override func setUp() async throws {
        // Create a ViewModel directly for testing
        viewModel = BaseConverterViewModel()
        
        // Create ContentView with our test ViewModel
        contentView = ContentView(viewModel: viewModel)
        
        // Set default values for testing
        viewModel.base10Input = "5"
        // Let the conversions happen
        await Task.yield()
    }
    
    func testIncrement() async {
        // Test incrementing with base10 input
        contentView.incrementValue(in: .base10)
        await Task.yield() // Allow async updates to complete
        
        // Check that the value was incremented
        XCTAssertEqual(viewModel.base10Input, "6")
        
        // Check that other bases were updated correctly
        XCTAssertEqual(viewModel.base2Input, "110")
        XCTAssertEqual(viewModel.base12Input, "6")
        XCTAssertEqual(viewModel.base16Input, "6")
    }
    
    func testDecrement() async {
        // Test decrementing with base10 input
        contentView.decrementValue(in: .base10)
        await Task.yield() // Allow async updates to complete
        
        // Check that the value was decremented
        XCTAssertEqual(viewModel.base10Input, "4")
        
        // Check that other bases were updated correctly
        XCTAssertEqual(viewModel.base2Input, "100")
        XCTAssertEqual(viewModel.base12Input, "4")
        XCTAssertEqual(viewModel.base16Input, "4")
    }
    
    func testIncrementFromZero() async {
        // Set value to zero
        viewModel.base10Input = "0"
        await Task.yield()
        
        // Increment
        contentView.incrementValue(in: .base10)
        await Task.yield()
        
        // Check that value changed from 0 to 1
        XCTAssertEqual(viewModel.base10Input, "1")
        XCTAssertEqual(viewModel.base2Input, "1")
        XCTAssertEqual(viewModel.base12Input, "1")
        XCTAssertEqual(viewModel.base16Input, "1")
    }
    
    func testDecrementFromZero() async {
        // Set value to zero
        viewModel.base10Input = "0"
        await Task.yield()
        
        // Decrement
        contentView.decrementValue(in: .base10)
        await Task.yield()
        
        // Check that value changed from 0 to -1
        XCTAssertEqual(viewModel.base10Input, "-1")
        XCTAssertEqual(viewModel.base2Input, "-1")
        XCTAssertEqual(viewModel.base12Input, "-1")
        XCTAssertEqual(viewModel.base16Input, "-1")
    }
    
    func testIncrementNegativeNumber() async {
        // Set a negative value
        viewModel.base10Input = "-5"
        await Task.yield()
        
        // Increment
        contentView.incrementValue(in: .base10)
        await Task.yield()
        
        // Check that value changed from -5 to -4
        XCTAssertEqual(viewModel.base10Input, "-4")
        XCTAssertEqual(viewModel.base2Input, "-100")
        XCTAssertEqual(viewModel.base12Input, "-4")
        XCTAssertEqual(viewModel.base16Input, "-4")
    }
    
    func testDecrementNegativeNumber() async {
        // Set a negative value
        viewModel.base10Input = "-5"
        await Task.yield()
        
        // Decrement
        contentView.decrementValue(in: .base10)
        await Task.yield()
        
        // Check that value changed from -5 to -6
        XCTAssertEqual(viewModel.base10Input, "-6")
        XCTAssertEqual(viewModel.base2Input, "-110")
        XCTAssertEqual(viewModel.base12Input, "-6")
        XCTAssertEqual(viewModel.base16Input, "-6")
    }
    
    func testIncrementEmptyInput() async {
        // Set empty input
        viewModel.base10Input = ""
        await Task.yield()
        
        // Increment should do nothing with empty input
        contentView.incrementValue(in: .base10)
        await Task.yield()
        
        // Check that values remain empty
        XCTAssertEqual(viewModel.base10Input, "")
        XCTAssertEqual(viewModel.base2Input, "")
        XCTAssertEqual(viewModel.base12Input, "")
        XCTAssertEqual(viewModel.base16Input, "")
    }
    
    func testDecrementEmptyInput() async {
        // Set empty input
        viewModel.base10Input = ""
        await Task.yield()
        
        // Decrement should do nothing with empty input
        contentView.decrementValue(in: .base10)
        await Task.yield()
        
        // Check that values remain empty
        XCTAssertEqual(viewModel.base10Input, "")
        XCTAssertEqual(viewModel.base2Input, "")
        XCTAssertEqual(viewModel.base12Input, "")
        XCTAssertEqual(viewModel.base16Input, "")
    }
    
    func testIncrementInvalidInput() async {
        // Set invalid input
        viewModel.base10Input = "ABC"
        await Task.yield()
        
        // Increment should do nothing with invalid input
        contentView.incrementValue(in: .base10)
        await Task.yield()
        
        // Check that invalid value remains unchanged
        XCTAssertEqual(viewModel.base10Input, "ABC")
    }
    
    func testDecrementInvalidInput() async {
        // Set invalid input
        viewModel.base10Input = "ABC"
        await Task.yield()
        
        // Decrement should do nothing with invalid input
        contentView.decrementValue(in: .base10)
        await Task.yield()
        
        // Check that invalid value remains unchanged
        XCTAssertEqual(viewModel.base10Input, "ABC")
    }
} 