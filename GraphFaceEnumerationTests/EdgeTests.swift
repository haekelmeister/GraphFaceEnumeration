import XCTest
@testable import GraphFaceEnumeration

class EdgeTests: XCTestCase {
    func testEdgesEquality() {
        let edgeA = Edge(Vertex(x: 0, y: 0), Vertex(x: 4, y: 4))
        let edgeB = Edge(Vertex(x: 0, y: 0), Vertex(x: 4, y: 4))
        let edgeC = Edge(Vertex(x: 4, y: 4), Vertex(x: 0, y: 0))
        let edgeD = Edge(Vertex(x: 4, y: 1), Vertex(x: 9, y: 1))
        
        XCTAssertNotNil(edgeA)
        
        XCTAssert(edgeA == edgeB)
        XCTAssert(edgeB == edgeC)
        XCTAssert(edgeA != edgeD)
    }
    
    func testAngleCalculation() {
        let edgeA = Edge(Vertex(x: 1, y: 1), Vertex(x: 9, y: 1))
        let edgeB = Edge(Vertex(x: 1, y: 1), Vertex(x: 1, y: 13))
        
        XCTAssert(edgeA!.calculateAngleClockwise(edgeA!) == 360.0)
        
        var angle = edgeA!.calculateAngleClockwise(edgeB!)
        XCTAssertNotNil(angle)
        XCTAssert(angle! == 270.0, "Angle must be 270° but is \(String(describing: angle))")
        
        // these edges do not cross each other, thus we do not get an angle
        let edgeC = Edge(Vertex(x: 5, y: 2), Vertex(x: 8, y: 7))
        XCTAssertNil(edgeA!.calculateAngleClockwise(edgeC!))
        
        let edgeD = Edge(Vertex(x: 0, y: 0), Vertex(x: 7, y: 7))
        let edgeE = Edge(Vertex(x: 0, y: 0), Vertex(x:-7, y: 7))
        let edgeF = Edge(Vertex(x: 0, y: 0), Vertex(x: 7, y: -7))
        let edgeG = Edge(Vertex(x: 0, y: 0), Vertex(x:-7, y: -7))
        let edgeH = Edge(Vertex(x:-6, y: 0), Vertex(x: 0, y: 0))
        
        angle = edgeD!.calculateAngleClockwise(edgeF!)
        XCTAssertNotNil(angle)
        XCTAssert(angle! == 90.0, "Angle must be 90° but is \(String(describing: angle))")
        
        angle = edgeF!.calculateAngleClockwise(edgeD!)
        XCTAssertNotNil(angle)
        XCTAssert(angle! == 270.0, "Angle must be 270° but is \(String(describing: angle))")
        
        angle = edgeD!.calculateAngleClockwise(edgeG!)
        XCTAssertNotNil(angle)
        XCTAssert(angle! == 180.0, "Angle must be 180° but is \(String(describing: angle))")
        
        angle = edgeG!.calculateAngleClockwise(edgeD!)
        XCTAssertNotNil(angle)
        XCTAssert(angle! == 180.0, "Angle must be 180° but is \(String(describing: angle))")
        
        angle = edgeD?.calculateAngleClockwise(edgeE!)
        XCTAssertNotNil(angle)
        XCTAssert(angle! == 270.0, "Angle must be 270° but is \(String(describing: angle))")
        
        angle = edgeE?.calculateAngleClockwise(edgeD!)
        XCTAssertNotNil(angle)
        XCTAssert(angle! == 90.0, "Angle must be 90° but is \(String(describing: angle))")
        
        angle = edgeH!.calculateAngleClockwise(edgeD!)
        XCTAssertNotNil(angle)
        XCTAssert(angle! == 135.0, "Angle must be 135° but is \(String(describing: angle))")
        
        angle = edgeD!.calculateAngleClockwise(edgeH!)
        XCTAssertNotNil(angle)
        XCTAssert(angle! == 225.0, "Angle must be 225° but is \(String(describing: angle))")
    }
}
