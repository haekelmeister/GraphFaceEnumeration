import CoreGraphics


/// This class describes a line. A lines doesn't belongs to the graph. Edges
/// however are constructed from lines. An edge accrues when a line is
/// intersected 2 times. Edges have a direction (means a start- and an endpoint).
class Line: Hashable, CustomStringConvertible {
    let start: CGPoint
    let end: CGPoint
    var vertex: Vertex?
    
    init?(_ start: CGPoint, _ end: CGPoint) {
        // that's a line, not a point
        if start == end {
            return nil
        }
        self.start = start
        self.end = end
    }
    
    /// Calcualtes the intersection point between 2 lines.
    ///
    /// - Parameter otheLine: the other line
    /// - Returns:  the intersection point between the 2 lines or nil in case they don't intersect
    func getIntersection(_ otherLine: Line) -> CGPoint? {
        
        let distance = (end.x - start.x) * (otherLine.end.y - otherLine.start.y) - (end.y - start.y) * (otherLine.end.x - otherLine.start.x)
        if distance == 0 {
            // parallel lines
            return nil
        }
        
        let u = ((otherLine.start.x - start.x) * (otherLine.end.y - otherLine.start.y) - (otherLine.start.y - start.y) * (otherLine.end.x - otherLine.start.x)) / distance
        let v = ((otherLine.start.x - start.x) * (end.y - start.y) - (otherLine.start.y - start.y) * (end.x - start.x)) / distance
        
        if (u < 0.0 || u > 1.0) {
            // intersection not inside this (self) line
            return nil
        }
        if (v < 0.0 || v > 1.0) {
            // intersection not inside line2
            return nil
        }
        
        return CGPoint(x: start.x + u * (end.x - start.x), y: start.y + u * (end.y - start.y))
    }
    
    static func == (lhs: Line, rhs: Line) -> Bool {
        return (lhs.start == rhs.start && lhs.end == rhs.end) ||
            (lhs.start == rhs.end && lhs.end == rhs.start)
    }
    
    var hashValue: Int {
        var x = start.x.description + end.x.description
        if start.x > end.x {
            x = end.x.description + start.x.description
        }
        
        var y = start.y.description + end.y.description
        if start.y > end.y {
            y = end.y.description + start.y.description
        }
        return String(x + y).hashValue
    }
    
    var description: String {
        return "[" + start.debugDescription + "-->" + end.debugDescription + "]"
    }
}
