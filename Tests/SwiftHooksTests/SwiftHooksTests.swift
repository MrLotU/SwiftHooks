import XCTest
@testable import SwiftHooks

final class SwiftHooksTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftHooks().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
