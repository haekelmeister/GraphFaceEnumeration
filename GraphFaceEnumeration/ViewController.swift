import UIKit
import os.log

class ViewController: UIViewController {
    
    @IBOutlet weak var intermediateImageView: UIImageView!
    @IBOutlet weak var finalImageView: UIImageView!
    
    var previewLineStartPoint = CGPoint.zero
    var previewLineEndPoint = CGPoint.zero
    let graph = Graph()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // get the shake gesture
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    private func clear() {
        finalImageView.image = nil
        intermediateImageView.image = nil
        previewLineStartPoint = CGPoint.zero
        previewLineEndPoint = CGPoint.zero
        graph.reset()
    }
    
    // MARK: - shake motion methods
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        switch motion {
        case .motionShake:
            let alertController = UIAlertController(title: "Clear", message: "Do you really want to clear the screen?", preferredStyle: UIAlertController.Style.alert)
            
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
            let clear = UIAlertAction(title: "Clear", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                self.clear()
            }
            
            alertController.addAction(cancel)
            alertController.addAction(clear)
            self.present(alertController, animated: true, completion: nil)
        default:
            os_log("Unhandled motion event '%@'", type: .debug, motion.description)
        }
    }

    // MARK: - line drawing/gathering logic
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            os_log("Touches are empty in touchesBegan", type: .error)
            return
        }
        
        previewLineStartPoint = touch.location(in: self.view)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            os_log("Touches are empty in touchesMoved", type: .error)
            return
        }
        
        previewLineEndPoint = touch.location(in: view)
        drawLineOnIntermediateImageView(from: previewLineStartPoint, to: previewLineEndPoint, withColor: UIColor.gray.cgColor)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            previewLineEndPoint = touch.location(in: view)
        }
        
        if previewLineStartPoint == previewLineEndPoint {
            // we handle just lines not dots
            return
        }

        graph.add(Line(previewLineStartPoint, previewLineEndPoint))
        
        UIGraphicsBeginImageContext(finalImageView.frame.size)
        
        for face in graph.findFaces() {
            if face.type != .inner {
                continue
            }
            
            let bezier = UIBezierPath()
            var previousCommonVertex = face.edges[0].commonVertex(face.edges[1])!
            bezier.move(to: face.edges[0].opposite(vertex: previousCommonVertex)!)
            bezier.addLine(to: previousCommonVertex)
            var previousEdge = face.edges.first!
            for currentEdge in face.edges.dropFirst() {
                if currentEdge != previousEdge {
                    previousCommonVertex = previousEdge.commonVertex(currentEdge)!
                    bezier.addLine(to: currentEdge.opposite(vertex: previousCommonVertex)!)
                }
                else {
                    bezier.addLine(to: previousCommonVertex)
                }
                previousEdge = currentEdge
            }
            
            
            bezier.close()
            UIColor.random().setFill()
            bezier.fill()
        }
        
        var vertices = Set<Vertex>() // highlight the intersection points, nothing more
//         var tvertices = [CGPoint]() // fake the tvertices form the algorithm description
        
        graph.lines.forEach { line in
            let b = UIBezierPath()
            b.move(to: line.start)
            b.addLine(to: line.end)
            UIColor.black.setStroke()
            //UIColor.random().setStroke()
            b.stroke()
            if let v = line.vertex {
                vertices.insert(v)
            }
        }
        
        graph.edges.forEach { edge in
            let b = UIBezierPath()
            b.move(to: edge.vertexA)
            b.addLine(to: edge.vertexB)
            UIColor.blue.setStroke()
            b.stroke()
            vertices.insert(edge.vertexA)
            vertices.insert(edge.vertexB)
            
//            if let tvertex = calculateTVertexPosition(edge: edge, distanceFromVertexA: edge.length/3) {
//                tvertices.append(tvertex)
//            }
//            
//            if let tvertex = calculateTVertexPosition(edge: edge, distanceFromVertexA: (edge.length/3)*2) {
//                tvertices.append(tvertex)
//            }
        }
        
        vertices.forEach { vertex in
            let b = UIBezierPath(arcCenter: vertex.point, radius: 1.0, startAngle: 0.0, endAngle: 2 * CGFloat.pi, clockwise: true)
            UIColor.red.setStroke()
            UIColor.red.setFill()
            b.stroke()
            b.fill()
        }
        
//        tvertices.forEach { tvertex in
//            let b = UIBezierPath(arcCenter: tvertex, radius: 2.0, startAngle: 0.0, endAngle: 2 * CGFloat.pi, clockwise: true)
//            UIColor.red.setStroke()
//            b.stroke()
//        }
        
        finalImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        intermediateImageView.image = nil
    }
    
    // MARK: - draw methods
    
    private func drawLineOnIntermediateImageView(from: CGPoint, to: CGPoint, withColor color: CGColor) {
        UIGraphicsBeginImageContext(view.frame.size)
        defer {
            UIGraphicsEndImageContext()
        }
        
        intermediateImageView.image = nil
        guard let context = UIGraphicsGetCurrentContext() else {
            os_log("Graphic context not found.", type: .error)
            return
        }
        
        context.move(to: from)
        context.addLine(to: to)
        
        context.setLineCap(CGLineCap.round)
        context.setLineWidth(2.0)
        context.setStrokeColor(color)
        context.setBlendMode(CGBlendMode.normal)
        
        context.strokePath()
        
        intermediateImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        intermediateImageView.alpha = 1.0
    }
}

// MARK: - useful extensions

extension CGPoint {
    func distance(_ otherPoint:CGPoint) -> CGFloat {
        return sqrt(pow(x - otherPoint.x, 2) + pow(y - otherPoint.y, 2))
    }
    
    static func == (lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: .random(), green: .random(), blue: .random(), alpha: 1.0)
    }
}

extension UIEvent.EventSubtype: CustomStringConvertible {
    public var description: String {
        switch self {
        case .motionShake: return "motionShake"
        case .none: return "none"
        case .remoteControlBeginSeekingBackward: return "remoteControlBeginSeekingBackward"
        case .remoteControlBeginSeekingForward: return "remoteControlBeginSeekingForward"
        case .remoteControlEndSeekingBackward: return "remoteControlEndSeekingBackward"
        case .remoteControlEndSeekingForward: return "remoteControlEndSeekingForward"
        case .remoteControlNextTrack: return "remoteControlNextTrack"
        case .remoteControlPause: return "remoteControlPause"
        case .remoteControlPlay: return "remoteControlPlay"
        case .remoteControlPreviousTrack: return "remoteControlPreviousTrack"
        case .remoteControlStop: return "remoteControlStop"
        case .remoteControlTogglePlayPause: return "remoteControlTogglePlayPause"
        }
    }
}

func calculateTVertexPosition(edge: Edge, distanceFromVertexA: Double) -> CGPoint? {
    if distanceFromVertexA < 0 {
        return nil
    }
    
    if distanceFromVertexA > edge.length {
        return nil
    }
    
    let x = edge.vertexA.point.x + CGFloat(distanceFromVertexA/edge.length)*(edge.vertexB.point.x - edge.vertexA.point.x)
    let y = edge.vertexA.point.y + CGFloat(distanceFromVertexA/edge.length)*(edge.vertexB.point.y - edge.vertexA.point.y)
    
    return CGPoint(x: x, y: y)
}


extension UIBezierPath {
    func addLine(to: Vertex) {
        self.addLine(to: to.point)
    }
    
    func move(to: Vertex) {
        self.move(to: to.point)
    }
}
