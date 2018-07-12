import CoreGraphics

/// A vertex is an endpoint of an edge.
struct Vertex: Hashable, CustomStringConvertible, CustomDebugStringConvertible {
    var point: CGPoint
    
    init(_ point: CGPoint) {
        self.point = point
    }
    
    init(x: Int, y: Int) {
        self.init(CGPoint(x: x, y: y))
    }
    
    /// Calculates the distance between 3 verticies in pixel.
    ///
    /// - Parameter otherVertex: the other vertex we want to calcualte the distence to
    /// - Returns: distance in pixel between the two verticies
    func distance(_ otherVertex: Vertex) -> CGFloat {
        return distance(otherVertex.point)
    }
    
    private func distance(_ otherPoint: CGPoint) -> CGFloat {
        let xDist = self.point.x - otherPoint.x
        let yDist = self.point.y - otherPoint.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    var hashValue: Int {
        return String(point.x.description + point.y.description).hashValue
    }
    
    var description: String {
        return point.x.description + "," + point.y.description
    }
    
    var debugDescription: String {
        return point.x.description + "," + point.y.description
    }

    static func == (lhs: CGPoint, rhs: Vertex) -> Bool {
        return lhs == rhs.point
    }
    
    static func == (lhs: Vertex, rhs: Vertex) -> Bool {
        return lhs.point == rhs.point
    }
    
    static func += (lhs: inout Vertex, rhs: CGPoint) {
        lhs.point.x += rhs.x
        lhs.point.y += rhs.y
    }
}

extension CGPoint {
    static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
}
