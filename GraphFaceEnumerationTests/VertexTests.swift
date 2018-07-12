import XCTest
@testable import GraphFaceEnumeration

class VertexTests: XCTestCase {
    func testVertexDistances() {
        let vertexA = Vertex(CGPoint(x: 0, y: 0))
        let vertexB = Vertex(CGPoint(x: 0, y: 4))
        
        XCTAssert(vertexA.distance(vertexB) == 4.0)
        XCTAssert(vertexB.distance(vertexA) == 4.0)
        XCTAssert(vertexA.distance(vertexA) == 0.0)
    }
}
