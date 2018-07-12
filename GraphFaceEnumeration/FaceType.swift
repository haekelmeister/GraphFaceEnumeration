import CoreGraphics

/// The kind of a graph face.
enum FaceType: Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    /// The inner area of a face
    case inner
    /// The outer area of a face
    case outer
    /// The face of this area is indefinite, could occur while drawing lines and the face is not finished yet
    case unknown(Int, CGFloat)
    
    var debugDescription: String {
        switch self {
        case .inner:
            return "FaceType.inner"
        case .outer:
            return "FaceType.outer"
        case .unknown:
            return "FaceType.unknown"
        }
    }
    
    var description: String {
        switch self {
        case .inner:
            return "inner"
        case .outer:
            return "outer"
        case .unknown:
            return "unknown"
        }
    }
}
