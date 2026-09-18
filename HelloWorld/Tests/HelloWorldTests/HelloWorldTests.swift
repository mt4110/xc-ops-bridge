import XCTest

#if canImport(HelloWorld)
@testable import HelloWorld
#endif

final class HelloWorldTests: XCTestCase {
    func testGreeting() {
        XCTAssertEqual(greeting(), "Hello, world!")
    }
}
