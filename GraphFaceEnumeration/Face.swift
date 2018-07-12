import CoreGraphics

/// Describes a graph face.
class Face: CustomStringConvertible {
    var edges: [Edge]
    var totalDegrees: CGFloat
    
    init() {
        self.edges = [Edge]()
        self.totalDegrees = 0.0
    }
    
    /// Calcualtes if the given edges from a circle. If true then we have a
    /// graph face.
    ///
    /// - Returns: true in case the edges form a circle, otherwise false
    var isFace: Bool {
        if edges.count < 3  {
            return false
        }
        
        let startEdge = edges.first!
        var lastEdge = startEdge
        for edge in edges.dropFirst() {
            if lastEdge.commonVertex(edge) != nil {
                lastEdge = edge
            }
            else {
                return false
            }
        }
        
        if lastEdge.commonVertex(startEdge) == nil {
            return false
        }
        
        return true
    }
    
    /// Signalise the kind of the graph face.
    ///
    /// - Returns: the kind of the graph face
    var type: FaceType {
        if !isFace {
            return .unknown(self.edges.count, self.totalDegrees)
        }
        
        let innerFace = 180 * (self.edges.count-2)
        let outerFace = 180 * (self.edges.count+2)
        
        if Int(self.totalDegrees.rounded()) <= innerFace { // should be equal ==
            return FaceType.inner
        }
        
        if Int(self.totalDegrees.rounded()) == outerFace {
            return FaceType.outer
        }
        
        return .unknown(self.edges.count, self.totalDegrees)
    }
    
    var description: String {
        return "Type=\(self.type.description), TtlAngle=\(self.totalDegrees), TtlEdges=\(self.edges.count)"
    }
}
