import XCTest

#if canImport(HelloWorld)
@testable import HelloWorld
#endif

// A simple test to verify testing infrastructure works correctly via xcodebuild/SPM
final class HelloWorldTests: XCTestCase {
    func testExample() throws {
        XCTAssertEqual(2 + 2, 4, "Math should work correctly")
    }
}
