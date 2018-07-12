import CoreGraphics
import os.log

/// Graph consists of edges. Edges are constructed out of lines. We draw lines
/// the devices and add them to the graph. The graph however calculates from the
/// intesection points of the lines the corresponding edges.
class Graph {
    var lines = Set<Line>() // lines are simple line drawings, they don't belong to the graph itself, we need them to calculate the vertices and edges
    var edges = Set<Edge>()
    
    func reset() {
        lines = Set<Line>()
        edges = Set<Edge>()
    }
    
    /// Calculates all faces of this graph.
    ///
    /// - Returns: array of faces
    func findFaces() -> [Face] {
        edges.forEach{ edge in
            edge.tagA = nil
            edge.tagB = nil
        }
        var faces = [Face]()
        
        var currentEdge = edges.first
        if currentEdge == nil {
            os_log("No edges available.")
            return faces
        }
        var currentVertex = currentEdge!.vertexA
        var currentTag: UInt = 1
        currentEdge!.tag(vertex: currentVertex, withTag: currentTag)
        var startEdge = currentEdge!
        var currentAngle: CGFloat = 0.0
        
        while true {
            let currentFace = Face()
            currentFace.edges.append(startEdge)
            
            while true {
                if let clockwiseAngle = nextEdgeClockwise(workingVertex: currentVertex, workingEdge: currentEdge!, edges: edges) {
                    currentEdge = clockwiseAngle.edge
                    currentAngle = clockwiseAngle.degreee
                }
                
                if currentEdge == nil {
                    os_log("Dead end found", type: .default)
                    break
                }
                
                if currentEdge! == startEdge {
                    if currentFace.edges.count > 2 {
                        currentFace.totalDegrees += currentAngle
                        // face found
                        faces.append(currentFace)
                    }
                    break
                }
                
                currentFace.edges.append(currentEdge!)
                currentFace.totalDegrees += currentAngle
                
                if let vertex = currentEdge!.opposite(vertex: currentVertex) {
                    currentVertex = vertex
                }
                else {
                    fatalError("Implementation error.")
                }
                
                currentEdge!.tag(vertex: currentVertex, withTag: currentTag)
            }
            
            if let edge = edges.first(where: {$0.tagA == nil || $0.tagB == nil} ) {
                currentEdge = edge
            }
            else {
                os_log("All edges processed.")
                break
            }
            
            currentTag += 1
            startEdge = currentEdge!
            
            if currentEdge!.tagA == nil {
                currentVertex = currentEdge!.vertexA
                currentEdge!.tagA = currentTag
            }
            else {
                currentVertex = currentEdge!.vertexB
                currentEdge!.tagB = currentTag
            }
        }
        
        return faces
    }
    
    private func nextEdgeClockwise(workingVertex: Vertex, workingEdge: Edge, edges: Set<Edge>) -> (edge: Edge, degreee: CGFloat)? {
        var foundEdges:[(edge: Edge, degree: CGFloat)] = []
        
        for edge in edges {
            if edge.hasVertex(vertex: workingVertex), let degree = workingEdge.calculateAngleClockwise(edge) {
                foundEdges.append((edge: edge, degree: degree))
            }
        }
        
        if foundEdges.count == 0 {
            return nil
        }
        
        foundEdges.sort { $0.degree < $1.degree }
        
        return (edge: foundEdges.first!.edge, degreee: foundEdges.first!.degree)
    }
    
    /// Adds a new line to this graph system. The line itself doesn't belongs to any
    /// calculation or the real graph. Lines who intersects forms edges. Those
    /// edges are used for the graph calculations.
    ///
    /// - Parameter line: the line to add to this graph
    func add(_ line: Line?) {
        guard let addedLine = line else {
            return
        }
        
        if lines.contains(addedLine) {
            return
        }
        
        var addedLineIntersectionPoints = [CGPoint]()
        var linesIntersections = [(line: Line, intersectionPoint: CGPoint)]()
        var edgesIntersections = [(edge: Edge, vertex: Vertex)]()
        
        for line in lines {
            let intercectionPoint = line.getIntersection(addedLine)
            if let point = intercectionPoint {
                addedLineIntersectionPoints.append(point)
                linesIntersections.append((line, point))
            }
        }
        
        for edge in edges {
            let intersectionVertex = edge.intesects(addedLine)
            if let vertex = intersectionVertex {
                addedLineIntersectionPoints.append(vertex.point)
                edgesIntersections.append((edge, vertex))
            }
        }
        
        if addedLineIntersectionPoints.count == 0 {
            lines.insert(addedLine)
            return
        }
        
        divide(addedLine, addedLineIntersectionPoints)
        
        divide(lines: linesIntersections)
        
        divide(edges: edgesIntersections)
    }
    
    private func divide(_ addedLine: Line, _ addedLineIntersectionPoints: [CGPoint]) {
        var intersectionPoints = addedLineIntersectionPoints
        intersectionPoints.sort {
            addedLine.start.distance($0) < addedLine.start.distance($1)
        }
        
        var currentPoint = addedLine.start
        for intersectionPoint in intersectionPoints {
            if intersectionPoint == intersectionPoints.first {
                // this assignment could and should fail in case the intersection-
                // point is equal the {START} point of the line
                if let line = Line(currentPoint, intersectionPoint) {
                    line.vertex = Vertex(intersectionPoint)
                    lines.insert(line)
                    currentPoint = intersectionPoint
                }
                
                continue
            }
            
            let vertexStart = Vertex(currentPoint)
            let vertexEnd = Vertex(intersectionPoint)
            if let edge = Edge(vertexStart, vertexEnd) {
                edges.insert(edge)
            }
            currentPoint = intersectionPoint
        }
        
        // this assignment could and should fail in case the intersection-
        // point is equal the {END} point of the line
        if let line = Line(currentPoint, addedLine.end) {
            line.vertex = Vertex(currentPoint)
            lines.insert(line)
        }
    }
    
    private func divide(lines intersectionPoints: [(line: Line, intersectionPoint: CGPoint)]) {
        for intersection in intersectionPoints {
            if let vertex = intersection.line.vertex {
                if intersection.line.start == vertex {
                    if let edge = Edge(vertex, Vertex(intersection.intersectionPoint)) {
                        edges.insert(edge)
                    }
                    
                    // this assigment could and should fail in case the vertex
                    // equals the {END}-point of the line because in this case
                    // we would create a simple point
                    if let line = Line(intersection.intersectionPoint, intersection.line.end) {
                        line.vertex = Vertex(intersection.intersectionPoint)
                        lines.insert(line)
                    }
                }
                else {
                    // this assigment could and should fail in case the vertex
                    // equals the {START}-point of the line because in this case
                    // we would create a simple point
                    if let line = Line(intersection.line.start, intersection.intersectionPoint) {
                        line.vertex = Vertex(intersection.intersectionPoint)
                        lines.insert(line)
                    }
                    
                    if let edge = Edge(Vertex(intersection.intersectionPoint), Vertex(intersection.line.end)) {
                        edges.insert(edge)
                    }
                }
                
                lines.remove(intersection.line)
            }
            else {
                if intersection.line.start == intersection.intersectionPoint || intersection.line.end == intersection.intersectionPoint {
                    intersection.line.vertex = Vertex(intersection.intersectionPoint)
                }
                else {
                    if let lineA = Line(intersection.line.start, intersection.intersectionPoint),
                        let lineB = Line(intersection.intersectionPoint, intersection.line.end) {
                        lineA.vertex = Vertex(intersection.intersectionPoint)
                        lineB.vertex = Vertex(intersection.intersectionPoint)
                        
                        lines.insert(lineA)
                        lines.insert(lineB)
                        lines.remove(intersection.line)
                    }
                    else {
                        fatalError("Error dividing lines. Line=\(intersection.line), Vertex=\(intersection.intersectionPoint)")
                    }
                }
            }
        }
    }
    
    private func divide(edges intersectionVertices: [(edge: Edge, vertex: Vertex)]) {
        for intersection in intersectionVertices {
            if let edgeA = Edge(intersection.edge.vertexA, intersection.vertex),
                let edgeB = Edge(intersection.vertex, intersection.edge.vertexB) {
                edges.insert(edgeA)
                edges.insert(edgeB)
                edges.remove(intersection.edge)
            }
            else {
                fatalError("Error dividing edge. Edge=\(intersection.edge), Vertex=\(intersection.edge)")
            }
        }
    }
}
