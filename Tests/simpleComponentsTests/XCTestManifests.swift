import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(simpleComponentsTests.allTests),
    ]
}
#endif
