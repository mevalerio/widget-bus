
import XCTest
@testable import tfl_api

class TfLServiceTests: XCTestCase {

    var sut: TfLService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = TfLService()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testExample() throws {
        XCTAssertNotNil(sut)
    }
}
