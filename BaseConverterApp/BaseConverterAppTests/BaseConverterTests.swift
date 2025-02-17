import XCTest
@testable import BaseConverterApp

final class BaseConverterTests: XCTestCase {
    func testDecimalToBase2() throws {
        XCTAssertEqual(try BaseConverter.convert(input: "10", from: 10, to: 2), "1010")
        XCTAssertEqual(try BaseConverter.convert(input: "15", from: 10, to: 2), "1111")
        XCTAssertEqual(try BaseConverter.convert(input: "0", from: 10, to: 2), "0")
        XCTAssertEqual(try BaseConverter.convert(input: "-10", from: 10, to: 2), "-1010")
    }
    
    func testDecimalToBase12() throws {
        XCTAssertEqual(try BaseConverter.convert(input: "10", from: 10, to: 12), "A")
        XCTAssertEqual(try BaseConverter.convert(input: "11", from: 10, to: 12), "B")
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
    
    func testBase12ToDecimal() throws {
        XCTAssertEqual(try BaseConverter.convert(input: "A", from: 12, to: 10), "10")
        XCTAssertEqual(try BaseConverter.convert(input: "B", from: 12, to: 10), "11")
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
        XCTAssertThrowsError(try BaseConverter.convert(input: "G", from: 16, to: 10))
        XCTAssertThrowsError(try BaseConverter.convert(input: "2", from: 2, to: 10))
        XCTAssertThrowsError(try BaseConverter.convert(input: "C", from: 12, to: 10))
    }
    
    func testUnsupportedBase() throws {
        XCTAssertThrowsError(try BaseConverter.convert(input: "10", from: 1, to: 10))
        XCTAssertThrowsError(try BaseConverter.convert(input: "10", from: 10, to: 17))
    }
    
    func testEmptyInput() throws {
        XCTAssertEqual(try BaseConverter.convert(input: "", from: 10, to: 2), "0")
        XCTAssertEqual(try BaseConverter.convert(input: "", from: 2, to: 16), "0")
    }
    
    func testOverflow() throws {
        // Test with a very large number that should cause overflow
        let largeBase2 = String(repeating: "1", count: 64)
        XCTAssertThrowsError(try BaseConverter.convert(input: largeBase2, from: 2, to: 10))
    }
} 