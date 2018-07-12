import CoreGraphics

/// Unlike lines, edges belongs to the graph. We construct edges from lines.
/// When a line got 2 vertices it becomes automatically an edge. Edges should (could)
/// not be added to the graph by the programmer, they are calculated out from lines.
/// Edges are undirected.
class Edge: Hashable, CustomStringConvertible, CustomDebugStringConvertible {
    let vertexA: Vertex
    let vertexB: Vertex
    let length: Double
    var tagA: UInt? // the tvertex tag close to vertex A
    var tagB: UInt? // the tvertex tag close to vertex B
    
    init?(_ vertexA: Vertex, _ vertexB: Vertex) {
        if vertexA == vertexB {
            return nil
        }
        
        self.vertexA = vertexA
        self.vertexB = vertexB
        self.length = sqrt( pow(Double(vertexA.point.x - vertexB.point.x), 2) + pow(Double(vertexA.point.y - vertexB.point.y),2) )
    }
    
    var hashValue: Int {
        var x = vertexA.point.x.description + vertexB.point.x.description
        if vertexA.point.x > vertexB.point.x {
            x = vertexB.point.x.description + vertexA.point.x.description
        }
        
        var y = vertexA.point.y.description + vertexB.point.y.description
        if vertexA.point.y > vertexB.point.y {
            y = vertexB.point.y.description + vertexA.point.y.description
        }
        
        return String(x + y).hashValue
    }
    
    var description: String {
        return "[" + vertexA.point.debugDescription + "-" + vertexB.point.debugDescription + "]"
    }
    
    var debugDescription: String {
        return "[" + vertexA.point.debugDescription + "-" + vertexB.point.debugDescription + "]"
    }
    
    static func == (lhs: Edge, rhs: Edge) -> Bool {
        return (lhs.vertexA == rhs.vertexA && lhs.vertexB == rhs.vertexB) ||
            (lhs.vertexA == rhs.vertexB && lhs.vertexB == rhs.vertexA)
    }
    
    func hasVertex(vertex: Vertex) -> Bool {
        return vertexA == vertex || vertexB == vertex
    }
    
    /// Calculates the angle between 2 edges in degrees clockwise (0°-360°). The
    /// edges have to have one vertex in common.
    ///
    /// - Parameter otherEdge: the second edge for the angle calculation
    /// - Returns: the angle in degrees or nil in case the edges have no common endpoint
    func calculateAngleClockwise(_ otherEdge: Edge) -> CGFloat? {
        var centre: Vertex?
        if self.vertexA == otherEdge.vertexA ||
            self.vertexA == otherEdge.vertexB {
            centre = self.vertexA
        }
        else if self.vertexB == otherEdge.vertexA ||
            self.vertexB == otherEdge.vertexB {
            centre = self.vertexB
        }
        
        // in case we have an edge without a common vertex
        guard let A = centre else {
            return nil
        }
        
        var B = vertexA == A ? vertexB : vertexA
        var C = otherEdge.vertexA == A ? otherEdge.vertexB : otherEdge.vertexA
        
        let shiftToOriginVector = CGPoint(x: A.point.x * -1, y: A.point.y * -1)
        
        B += shiftToOriginVector
        C += shiftToOriginVector
        
        // use degrees instead of radians because I used to it :)
        var degreesB = toDegrees(atan2(B.point.y, B.point.x))
        var degreesC = toDegrees(atan2(C.point.y, C.point.x))
        
        degreesB = toClockwiseDegrees(degreesB)
        degreesC = toClockwiseDegrees(degreesC)
        
        let result = degreesB < degreesC ? degreesC - degreesB : (360 - degreesB) + degreesC
        
        return result
    }
    
    private func toDegrees(_ atan2Radians: CGFloat) -> CGFloat {
        return atan2Radians*180/CGFloat.pi
    }
    
    private func toClockwiseDegrees(_ atan2Degrees: CGFloat) -> CGFloat {
        return atan2Degrees <= 0 ? atan2Degrees * -1 : 360 - atan2Degrees
    }
    
    
    /// Tag an given vertex (or TVertex in the algorithm) with the given tag.
    ///
    /// - Parameter vertex: the vertex to be tagged
    /// - Parameter withTag: the tag
    func tag(vertex: Vertex, withTag tag: UInt) {
        if vertex == vertexA {
            tagA = 1
            return
        }
        
        if vertex == vertexB {
            tagB = 1
            return
        }
        
        assertionFailure("Programmer error, given vertex doesn't belongs to this edge. Vertex=\(vertex)")
    }
    
    /// Return the oposite vertex to the given one.
    ///
    /// - Parameter vertex: the oposite vertex to the returned one
    /// - Returns: the oposite vertex to the given one or nil in case the given vertex doesn't belongs to this edge
    func opposite(vertex: Vertex) -> Vertex? {
        if vertex == vertexA {
            return vertexB
        }
        
        if vertex == vertexB {
            return vertexA
        }
        
        assertionFailure("Programmer error, the given vertex does not belongs to this edge.")
        return nil
    }
    
    /// Return the common vertex of both edges. In case we have to calculate the
    /// common vertex of the same edge, than vertex A is returned. This is
    /// because vertex A and vertex B is common is both edges and we need to retrun
    /// one vertex.
    ///
    /// - Parameter edge: the other edge where we will try to find a common vertex
    /// - Returns: common vertex of both edges or nil in case the edges doesn't have a common vertex (they don't intersect), in case we shall calculate the common vertex of self we return vertex A
    func commonVertex(_ edge: Edge) -> Vertex? {
        
        // in case we have to determine the common vertex with itself
        // the we return vertex A cos we have to take one vertex :)
        if vertexA == edge.vertexA || vertexA == edge.vertexB {
            return vertexA
        }
        
        if vertexB == edge.vertexA || vertexB == edge.vertexB {
            return vertexB
        }
        
        return nil
    }
    
    /// Calculates the intersection point of this edge and a line.
    ///
    /// - Parameter line: the intersected line
    /// - Returns: the intersection point (as vertex because we need this particular point as a vertex later on) or nil in case the edge and the line doesn't intersects
    func intesects(_ line: Line) -> Vertex? {
        
        let distance = (vertexB.point.x - vertexA.point.x) * (line.end.y - line.start.y) - (vertexB.point.y - vertexA.point.y) * (line.end.x - line.start.x)
        if distance == 0 {
            // parallel lines
            return nil
        }
        
        let u = ((line.start.x - vertexA.point.x) * (line.end.y - line.start.y) - (line.start.y - vertexA.point.y) * (line.end.x - line.start.x)) / distance
        let v = ((line.start.x - vertexA.point.x) * (vertexB.point.y - vertexA.point.y) - (line.start.y - vertexA.point.y) * (vertexB.point.x - vertexA.point.x)) / distance
        
        if u < 0.0 || u > 1.0 {
            // intersection not inside this (self) line
            return nil
        }
        if v < 0.0 || v > 1.0 {
            // intersection not inside line2
            return nil
        }
        
        let cgPoint = CGPoint(x: vertexA.point.x + u * (vertexB.point.x - vertexA.point.x), y: vertexA.point.y + u * (vertexB.point.y - vertexA.point.y))
        return Vertex(cgPoint)
    }
}
