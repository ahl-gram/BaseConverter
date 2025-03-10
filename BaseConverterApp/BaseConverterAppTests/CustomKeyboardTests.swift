import XCTest
import SwiftUI
@testable import BaseConverterApp

final class CustomKeyboardTests: XCTestCase {
    
    // Test key color assignment logic
    func testKeyColors() {
        let keyboard = CustomKeyboard(onKeyTap: { _ in })
        
        // Test binary colors
        XCTAssertEqual(keyboard.colorForKey("0"), BaseTheme.binary)
        XCTAssertEqual(keyboard.colorForKey("1"), BaseTheme.binary)
        
        // Test decimal colors
        XCTAssertEqual(keyboard.colorForKey("2"), BaseTheme.decimal)
        XCTAssertEqual(keyboard.colorForKey("9"), BaseTheme.decimal)
        
        // Test duodecimal colors
        XCTAssertEqual(keyboard.colorForKey("X"), BaseTheme.duodecimal)
        XCTAssertEqual(keyboard.colorForKey("E_DUO"), BaseTheme.duodecimal)
        
        // Test hexadecimal colors
        XCTAssertEqual(keyboard.colorForKey("A"), BaseTheme.hexadecimal)
        XCTAssertEqual(keyboard.colorForKey("F"), BaseTheme.hexadecimal)
        XCTAssertEqual(keyboard.colorForKey("E_HEX"), BaseTheme.hexadecimal)
        
        // Test misc colors
        XCTAssertEqual(keyboard.colorForKey("-"), Color.gray)
    }
    
    // Test key validation for each base
    func testKeyValidation() {
        // Setup keyboards for different bases
        let keyboardWithBase2 = CustomKeyboard(onKeyTap: { _ in }, focusedField: .base2)
        let keyboardWithBase10 = CustomKeyboard(onKeyTap: { _ in }, focusedField: .base10)
        let keyboardWithBase12 = CustomKeyboard(onKeyTap: { _ in }, focusedField: .base12)
        let keyboardWithBase16 = CustomKeyboard(onKeyTap: { _ in }, focusedField: .base16)
        
        // Test binary field validation
        XCTAssertTrue(keyboardWithBase2.isKeyValid("0"))
        XCTAssertTrue(keyboardWithBase2.isKeyValid("1"))
        XCTAssertFalse(keyboardWithBase2.isKeyValid("2"))
        XCTAssertFalse(keyboardWithBase2.isKeyValid("A"))
        XCTAssertFalse(keyboardWithBase2.isKeyValid("X"))
        XCTAssertTrue(keyboardWithBase2.isKeyValid("-"))  // Negative sign should be valid for all bases
        XCTAssertFalse(keyboardWithBase2.isKeyValid("E_DUO"))
        XCTAssertFalse(keyboardWithBase2.isKeyValid("E_HEX"))
        
        // Test decimal field validation
        XCTAssertTrue(keyboardWithBase10.isKeyValid("0"))
        XCTAssertTrue(keyboardWithBase10.isKeyValid("9"))
        XCTAssertFalse(keyboardWithBase10.isKeyValid("A"))
        XCTAssertFalse(keyboardWithBase10.isKeyValid("X"))
        XCTAssertFalse(keyboardWithBase10.isKeyValid("E_DUO"))
        XCTAssertFalse(keyboardWithBase10.isKeyValid("E_HEX"))
        
        // Test duodecimal field validation
        XCTAssertTrue(keyboardWithBase12.isKeyValid("0"))
        XCTAssertTrue(keyboardWithBase12.isKeyValid("9"))
        XCTAssertTrue(keyboardWithBase12.isKeyValid("X"))
        XCTAssertTrue(keyboardWithBase12.isKeyValid("E_DUO"))
        XCTAssertFalse(keyboardWithBase12.isKeyValid("A"))  // A is not valid in base 12
        XCTAssertFalse(keyboardWithBase12.isKeyValid("E_HEX"))  // Hex E should be disabled in base 12
        
        // Test hexadecimal field validation
        XCTAssertTrue(keyboardWithBase16.isKeyValid("0"))
        XCTAssertTrue(keyboardWithBase16.isKeyValid("9"))
        XCTAssertTrue(keyboardWithBase16.isKeyValid("A"))
        XCTAssertTrue(keyboardWithBase16.isKeyValid("F"))
        XCTAssertFalse(keyboardWithBase16.isKeyValid("X"))  // X is not valid in base 16
        XCTAssertFalse(keyboardWithBase16.isKeyValid("E_DUO"))  // Duodecimal E should be disabled in base 16
        XCTAssertTrue(keyboardWithBase16.isKeyValid("E_HEX"))  // Hex E should be enabled in base 16
        
        // Test no focused field
        let keyboardWithNoFocus = CustomKeyboard(onKeyTap: { _ in })
        XCTAssertFalse(keyboardWithNoFocus.isKeyValid("0"))  // All keys should be disabled when no field is focused
        XCTAssertFalse(keyboardWithNoFocus.isKeyValid("A"))
        XCTAssertFalse(keyboardWithNoFocus.isKeyValid("-"))
    }
    
    // Test key display
    func testKeyDisplay() {
        let keyboard = CustomKeyboard(onKeyTap: { _ in })
        
        // Test regular keys
        XCTAssertEqual(keyboard.displayKey("A"), "A")
        XCTAssertEqual(keyboard.displayKey("9"), "9")
        XCTAssertEqual(keyboard.displayKey("-"), "-")
        
        // Test special keys
        XCTAssertEqual(keyboard.displayKey("E_DUO"), "E")
        XCTAssertEqual(keyboard.displayKey("E_HEX"), "E")
    }
    
    // Test key tap handling
    func testKeyTapHandling() {
        // Setup a test expectation
        let expectation = XCTestExpectation(description: "Key tap handled")
        
        // Create a keyboard with a tap handler that records tapped keys
        var tappedKey: String?
        let keyboard = CustomKeyboard(onKeyTap: { key in
            tappedKey = key
            expectation.fulfill()
        })
        
        // Test regular key
        keyboard.handleKeyTap("A")
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(tappedKey, "A")
        
        // Reset for next test
        tappedKey = nil
        let expectation2 = XCTestExpectation(description: "Special key tap handled")
        
        // Set up a new keyboard for this test
        let keyboard2 = CustomKeyboard(onKeyTap: { key in
            tappedKey = key
            expectation2.fulfill()
        })
        
        // Test duodecimal E key - should output "E" not "E_DUO"
        keyboard2.handleKeyTap("E_DUO")
        wait(for: [expectation2], timeout: 1.0)
        XCTAssertEqual(tappedKey, "E")
        
        // Reset for next test
        tappedKey = nil
        let expectation3 = XCTestExpectation(description: "Hex key tap handled")
        
        // Set up a new keyboard for this test
        let keyboard3 = CustomKeyboard(onKeyTap: { key in
            tappedKey = key
            expectation3.fulfill()
        })
        
        // Test hexadecimal E key - should output "E" not "E_HEX"
        keyboard3.handleKeyTap("E_HEX")
        wait(for: [expectation3], timeout: 1.0)
        XCTAssertEqual(tappedKey, "E")
    }
} 