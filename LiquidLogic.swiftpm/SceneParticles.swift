import SpriteKit

// MARK: - Water & Scene Controls Extension
extension LiquidScene {
    
    func spawnWaterParticle(at pos: CGPoint, applyJitter: Bool, initialVelocity: CGVector? = nil) {
        let dropRadius: CGFloat = 2.25 
        let drop = SKShapeNode(circleOfRadius: dropRadius)
        
        drop.fillColor = .clear
        drop.strokeColor = UIColor(red: 0.2, green: 0.9, blue: 1.0, alpha: 1.0)
        drop.glowWidth = 18.0 
        drop.blendMode = .add 
        
        if applyJitter {
            let jitterX = CGFloat.random(in: -3...3)
            drop.position = CGPoint(x: pos.x + jitterX, y: pos.y)
        } else {
            drop.position = pos
        }
        
        drop.userData = ["stationaryTime": 0.0]
        
        let body = SKPhysicsBody(circleOfRadius: dropRadius)
        body.mass = 0.03 
        body.restitution = 0.1
        body.friction = 0.1
        body.categoryBitMask = PhysicsCategory.water
        body.contactTestBitMask = PhysicsCategory.goal
        body.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.water
        
        if let velocity = initialVelocity { body.velocity = velocity }
        
        drop.physicsBody = body
        waterNodeLayer.addChild(drop)
    }
    
    func didBegin(_ contact: SKPhysicsContact) { }
    
    func resetScene() {
        waterNodeLayer.removeAllChildren()
        isGameActive = true
        isF1On = false; isF2On = false; isF3On = false; isF4On = false
        goalContactDuration = 0.0
        goalNode.alpha = 0.3
        
        for gate in gates {
            gate.isActive = false
            gate.stateTimer = 0.0
            gate.recentHitsA.removeAll()
            gate.recentHitsB.removeAll()
            gate.sustainedTimeA = 0.0
            gate.sustainedTimeB = 0.0
        }
    }
}
