import SpriteKit

extension LiquidScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEditingMode, let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if editorTool == "draw" {
            drawStartPos = location
            drawPreviewNode = SKSpriteNode(color: UIColor.darkGray.withAlphaComponent(0.6), size: CGSize(width: 0, height: 16))
            drawPreviewNode?.zPosition = 100
            
            let outline = SKShapeNode(rectOf: CGSize(width: 0, height: 16))
            outline.strokeColor = .green; outline.lineWidth = 2.0; outline.name = "outline"
            drawPreviewNode?.addChild(outline)
            if let preview = drawPreviewNode { addChild(preview) }
            return
        }
        
        if editorTool == "wall" {
            createPlatform(at: location, width: 100, angle: 0)
            return
        }
        
        let touchedNodes = nodes(at: location)
        
        if editorTool == "eraser" {
            for node in touchedNodes where node.name == "customWall" { node.removeFromParent(); return }
        } else if editorTool == "move" {
            for node in touchedNodes {
                if let name = node.name, name.contains("customWall") || name.contains("machine") || name.contains("goal") || name.contains("faucet") {
                    draggedNode = node
                    if name == "customWall" { node.zRotation += .pi / 4 }
                    return
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEditingMode, let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if editorTool == "draw", let start = drawStartPos, let preview = drawPreviewNode {
            let dx = location.x - start.x
            let dy = location.y - start.y
            let dist = hypot(dx, dy)
            let angle = atan2(dy, dx)
            
            preview.size.width = dist
            preview.position = CGPoint(x: start.x + dx/2, y: start.y + dy/2)
            preview.zRotation = angle
            if let outline = preview.childNode(withName: "outline") as? SKShapeNode {
                outline.path = CGPath(rect: CGRect(x: -dist/2, y: -8, width: dist, height: 16), transform: nil)
            }
            return
        }
        
        guard let node = draggedNode, let name = node.name else { return }
        
        // when dragging the machine body, we move all the attached parts together
        if name.starts(with: "machine_") {
            let id = Int(name.split(separator: "_")[1])!
            if let gate = gates.first(where: { $0.id == id }) {
                let dx = location.x - gate.body.position.x
                let dy = location.y - gate.body.position.y
                gate.body.position = location
                gate.sensorA.position = CGPoint(x: gate.sensorA.position.x + dx, y: gate.sensorA.position.y + dy)
                gate.sensorB.position = CGPoint(x: gate.sensorB.position.x + dx, y: gate.sensorB.position.y + dy)
                gate.outputPos = CGPoint(x: gate.outputPos.x + dx, y: gate.outputPos.y + dy)
            }
        } else if name == "faucet1" { node.position = location; faucet1Pos = location }
        else if name == "faucet2" { node.position = location; faucet2Pos = location }
        else if name == "faucet3" { node.position = location; faucet3Pos = location }
        else if name == "faucet4" { node.position = location; faucet4Pos = location }
        else { node.position = location }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEditingMode, let touch = touches.first else { return }
        if editorTool == "draw", let start = drawStartPos {
            let loc = touch.location(in: self)
            let dist = hypot(loc.x - start.x, loc.y - start.y)
            if dist > 15 {
                createPlatform(at: CGPoint(x: start.x + (loc.x - start.x)/2, y: start.y + (loc.y - start.y)/2), width: dist, angle: atan2(loc.y - start.y, loc.x - start.x))
            }
            drawPreviewNode?.removeFromParent()
            drawPreviewNode = nil; drawStartPos = nil
        }
        draggedNode = nil
    }
}
