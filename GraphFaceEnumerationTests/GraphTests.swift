import XCTest
@testable import GraphFaceEnumeration

class GraphTests: XCTestCase {
    func testEdgeCreation() {
        let graph = Graph()
        
        graph.add(Line(CGPoint(x: 0, y: 0), CGPoint(x:10, y: 0)))
        graph.add(Line(CGPoint(x:10, y: 0), CGPoint(x: 0, y:10)))
        graph.add(Line(CGPoint(x: 0, y:10), CGPoint(x: 0, y: 0)))
        
        XCTAssert(graph.edges.count == 3)
        XCTAssert(graph.lines.count == 0)
        
        XCTAssert(graph.edges.filter { $0 == Edge(Vertex(x: 0, y: 0), Vertex(x:10, y: 0))}.count == 1 )
        XCTAssert(graph.edges.filter { $0 == Edge(Vertex(x:10, y: 0), Vertex(x: 0, y:10))}.count == 1 )
        XCTAssert(graph.edges.filter { $0 == Edge(Vertex(x: 0, y:10), Vertex(x: 0, y: 0))}.count == 1 )
    }
    
    func testLineCreation() {
        let graph = Graph()
        
        graph.add(Line(CGPoint(x: -2, y: -2), CGPoint(x: 15, y: 2)))
        graph.add(Line(CGPoint(x: 12, y: -1), CGPoint(x: 18, y:11)))
        graph.add(Line(CGPoint(x: 18, y: 11), CGPoint(x: -4, y: 2)))
        graph.add(Line(CGPoint(x: -3, y: 3), CGPoint(x: -1, y: -3)))
        
        XCTAssert(graph.lines.count == 6)
        XCTAssert(graph.edges.count == 4)
    }
    
    func testLinesFaceDetection() {
        let graph = Graph()
        graph.add(Line(CGPoint(x:  5.0, y:  8.0), CGPoint(x: 30.0, y: 8.0)))
        graph.add(Line(CGPoint(x: 30.0, y: 35.0), CGPoint(x: 30.0, y: 8.0)))
        graph.add(Line(CGPoint(x: 30.0, y: 35.0), CGPoint(x:  4.0, y:20.0)))
        
        
        XCTAssert(graph.lines.count == 2)
        XCTAssert(graph.edges.count == 1)
        
        let faces = graph.findFaces()
        XCTAssert(faces.count == 0)
    }
    
    func testTriangleFaceDetection() {
        let graph = Graph()
        graph.add(Line(CGPoint(x:  5.0, y:  8.0), CGPoint(x: 30.0, y: 8.0)))
        graph.add(Line(CGPoint(x: 30.0, y: 35.0), CGPoint(x: 30.0, y: 8.0)))
        graph.add(Line(CGPoint(x: 30.0, y: 35.0), CGPoint(x:  5.0, y: 8.0)))
        
        
        XCTAssert(graph.lines.count == 0)
        XCTAssert(graph.edges.count == 3)
        
        let faces = graph.findFaces()
        
        XCTAssert(faces.count == 2)
        
        for face in faces {
            if face.type == .inner {
                XCTAssert(face.totalDegrees.rounded() == 180.0)
            }
            if face.type == .outer {
                XCTAssert(face.totalDegrees.rounded() == 900.0)
            }
            XCTAssert(face.edges.count == 3)
        }
    }
    
    func testRectangleWithCross() {
        let graph = Graph()
        graph.add(Line(CGPoint(x: 1, y: 1), CGPoint(x: 8, y: 1)))
        graph.add(Line(CGPoint(x: 8, y: 1), CGPoint(x: 8, y: 8)))
        graph.add(Line(CGPoint(x: 8, y: 8), CGPoint(x: 1, y: 8)))
        graph.add(Line(CGPoint(x: 1, y: 8), CGPoint(x: 1, y: 1)))
        graph.add(Line(CGPoint(x: 4, y: 0), CGPoint(x: 4, y: 4)))
        graph.add(Line(CGPoint(x: 2, y: 2), CGPoint(x: 6, y: 2)))
        
        
        XCTAssert(graph.edges.count == 6)
        XCTAssert(graph.lines.count == 4)
        
        for face in graph.findFaces() {
            print(face)
        }
    }

    
    func testIsFace() {
        let face = Face()
        XCTAssert(!face.isFace)
        face.edges.append(Edge(Vertex(x: 1, y: 1), Vertex(x: 8, y: 1))!)
        XCTAssert(!face.isFace)
        face.edges.append(Edge(Vertex(x: 8, y: 1), Vertex(x: 8, y: 8))!)
        XCTAssert(!face.isFace)
        face.edges.append(Edge(Vertex(x: 8, y: 8), Vertex(x: 1, y: 8))!)
        XCTAssert(!face.isFace)
        
        face.edges.append(Edge(Vertex(x: 1, y: 8), Vertex(x: 1, y: 1))!)
        XCTAssert(face.isFace)
    }
}
