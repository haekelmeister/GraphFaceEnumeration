import XCTest
@testable import GraphFaceEnumeration

class LineTests: XCTestCase {
    func testParallelLines() {
        let lineA = Line(CGPoint(x: 5, y: 0), CGPoint(x: 15, y: 0))
        let lineB = Line(CGPoint(x: 5, y: 1), CGPoint(x: 15, y: 1))
        
        XCTAssertNil(lineA!.getIntersection(lineB!))
    }
    
    func testLineIntersection() {
        let lineA = Line(CGPoint(x: 1, y: 1), CGPoint(x: 50, y: 50))
        let lineB = Line(CGPoint(x: 25, y: 50), CGPoint(x: 50, y: 1))
        
        XCTAssertNotNil(lineA!.getIntersection(lineB!))
    }
    
    func testLineNoIntersection() {
        let lineA = Line(CGPoint(x: 0, y: 0), CGPoint(x: 5, y: 5))
        let lineB = Line(CGPoint(x: 3, y: 2), CGPoint(x: 5, y: 0))
        
        XCTAssertNil(lineA!.getIntersection(lineB!))
    }
    
    func testLinesEquality() {
        let lineA = Line(CGPoint(x: 0, y: 0), CGPoint(x: 5, y: 5))
        let lineB = Line(CGPoint(x: 0, y: 0), CGPoint(x: 5, y: 5))
        let lineC = Line(CGPoint(x: 5, y: 5), CGPoint(x: 0, y: 0))
        let lineD = Line(CGPoint(x: 6, y: 6), CGPoint(x: 0, y: 0))
        
        XCTAssert(lineA == lineB)
        XCTAssert(lineB == lineC)
        XCTAssert(lineA != lineD)
    }
    
    func testSetInsertRemove() {
        var lines = Set<Line>()
        let lineA = Line(CGPoint(x: 3, y: 5), CGPoint(x: 6, y: 90))
        let lineB = Line(CGPoint(x: 6, y: 90), CGPoint(x: 3, y: 5))
        
        XCTAssert(lines.count == 0)
        XCTAssert(lines.insert(lineA!).inserted)
        XCTAssert(!lines.insert(lineA!).inserted)
        XCTAssert(!lines.insert(lineB!).inserted)
        XCTAssert(lines.remove(lineA!) == lineA)
        XCTAssert(lines.count == 0)
    }
    
    func testLineDividing() {
        let lineA = Line(CGPoint(x: 2, y: 1), CGPoint(x: 2, y: 3))
        let lineB = Line(CGPoint(x: 8, y: 1), CGPoint(x: 8, y: 2))
        let lineC = Line(CGPoint(x: 3, y: 1), CGPoint(x: 3, y: 3))
        let lineD = Line(CGPoint(x: 2, y: 2), CGPoint(x: 8, y: 2))
        let graph = Graph()
        
        XCTAssert(graph.lines.count == 0)
        XCTAssert(graph.edges.count == 0)
        
        graph.add(lineA)
        XCTAssert(graph.lines.count == 1)
        XCTAssert(graph.edges.count == 0)
        
        graph.add(lineB)
        XCTAssert(graph.lines.count == 2)
        XCTAssert(graph.edges.count == 0)
        
        graph.add(lineC)
        XCTAssert(graph.lines.count == 3)
        XCTAssert(graph.edges.count == 0)
        
        graph.add(lineD)
        XCTAssert(graph.lines.count == 5)
        XCTAssert(graph.edges.count == 2)
    }
}
