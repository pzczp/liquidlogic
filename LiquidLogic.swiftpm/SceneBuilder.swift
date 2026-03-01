import SpriteKit

extension LiquidScene {
    
    func buildLevel() {
        if currentLevel == 1 { buildL1() }
        else if currentLevel == 2 { buildL2() }
        else if currentLevel == 3 { buildL3() }
        else if currentLevel == 4 { buildL4() }
        else if currentLevel == 5 { buildL5() }
        else if currentLevel == 6 { buildEditor() }
    }
    
    // level 1: basic AND
    func buildL1() {
        buildCommon(goalPos: CGPoint(x: 200, y: 80))
        createGate(id: 1, type: 1, pos: CGPoint(x: 200, y: 440)) // AND
        
        createPlatform(at: CGPoint(x: 80, y: 560), width: 80, angle: -0.7)
        createPlatform(at: CGPoint(x: 180, y: 560), width: 80, angle: 0.7)
        createPlatform(at: CGPoint(x: 220, y: 560), width: 80, angle: -0.7)
        createPlatform(at: CGPoint(x: 320, y: 560), width: 80, angle: 0.7)
        
        addHint(text: "AND gates require BOTH streams", pos: CGPoint(x: 200, y: 300))
    }
    
    // level 2: completely revamped OR puzzle
    // you have to bounce faucet 1 into the OR gate, or combine 2 and 3 into the AND gate
    func buildL2() {
        buildCommon(goalPos: CGPoint(x: 320, y: 80))
        
        createGate(id: 1, type: 1, pos: CGPoint(x: 120, y: 500)) // AND
        createGate(id: 2, type: 2, pos: CGPoint(x: 280, y: 300)) // OR
        
        // funnel f1 and f2 into the AND gate
        createPlatform(at: CGPoint(x: 50, y: 600), width: 60, angle: -0.5)
        createPlatform(at: CGPoint(x: 100, y: 600), width: 60, angle: 0.5)
        createPlatform(at: CGPoint(x: 140, y: 600), width: 60, angle: -0.5)
        createPlatform(at: CGPoint(x: 190, y: 600), width: 60, angle: 0.5)
        
        // funnel AND output into the OR gate's left sensor
        createPlatform(at: CGPoint(x: 170, y: 400), width: 150, angle: -0.3)
        
        // big ramp for faucet 4 to cross the screen into the OR gate's right sensor
        createPlatform(at: CGPoint(x: 320, y: 600), width: 150, angle: 0.4)
        createPlatform(at: CGPoint(x: 360, y: 450), width: 100, angle: -0.6)
        
        addHint(text: "OR gates only need ONE active stream", pos: CGPoint(x: 200, y: 200))
    }
    
    // level 3: completely revamped NOT puzzle
    // the NOT gate is blocking the goal. you have to use an AND gate to trigger the NOT gate to turn it off!
    func buildL3() {
        buildCommon(goalPos: CGPoint(x: 200, y: 80))
        
        createGate(id: 1, type: 1, pos: CGPoint(x: 120, y: 550)) // AND
        createGate(id: 2, type: 3, pos: CGPoint(x: 200, y: 300)) // NOT
        
        // simple funnels for the AND
        createPlatform(at: CGPoint(x: 80, y: 650), width: 80, angle: -0.5)
        createPlatform(at: CGPoint(x: 160, y: 650), width: 80, angle: 0.5)
        
        // ramp the AND output down into the NOT gate's single sensor
        createPlatform(at: CGPoint(x: 160, y: 450), width: 120, angle: -0.4)
        
        // ramp faucet 4 straight into the goal, BUT it's blocked if the NOT gate is flowing!
        createPlatform(at: CGPoint(x: 300, y: 400), width: 200, angle: 0.6)
        
        addHint(text: "NOT gates flow UNLESS they are hit by water", pos: CGPoint(x: 200, y: 200))
    }
    
    // level 4: completely revamped XOR chaos
    // multiple gates trying to cross each other
    func buildL4() {
        buildCommon(goalPos: CGPoint(x: 200, y: 80))
        
        createGate(id: 1, type: 4, pos: CGPoint(x: 200, y: 500)) // XOR
        createGate(id: 2, type: 1, pos: CGPoint(x: 200, y: 250)) // AND
        
        // funnel f2 and f3 into the XOR
        createPlatform(at: CGPoint(x: 140, y: 600), width: 80, angle: -0.5)
        createPlatform(at: CGPoint(x: 260, y: 600), width: 80, angle: 0.5)
        
        // funnel XOR output straight down to AND's left sensor
        createPlatform(at: CGPoint(x: 150, y: 400), width: 100, angle: -0.5)
        
        // funnel f4 way down to the AND's right sensor
        createPlatform(at: CGPoint(x: 350, y: 500), width: 100, angle: 0.7)
        createPlatform(at: CGPoint(x: 280, y: 350), width: 120, angle: -0.5)
        
        addHint(text: "XOR gates JAM if both streams hit them!", pos: CGPoint(x: 200, y: 150))
    }
    
    // level 5: pure gravity maze, no gates
    func buildL5() {
        buildCommon(goalPos: CGPoint(x: 350, y: 50))
        
        // giant zig zag platforms
        createPlatform(at: CGPoint(x: 180, y: 600), width: 350, angle: 0) // gap on right
        createPlatform(at: CGPoint(x: 220, y: 400), width: 350, angle: 0) // gap on left
        createPlatform(at: CGPoint(x: 180, y: 200), width: 350, angle: 0) // gap on right
        
        addHint(text: "Unlock gravity and TILT your device to slosh the water!", pos: CGPoint(x: 200, y: 700))
    }
    
    // level 6: editor template
    func buildEditor() {
        buildCommon(goalPos: CGPoint(x: 200, y: 80))
        createGate(id: 1, type: 1, pos: CGPoint(x: 200, y: 440))
        addHint(text: "Draw walls, drag items, build puzzles.", pos: CGPoint(x: 200, y: 300))
    }
    
    // --- helpers ---
    func buildCommon(goalPos: CGPoint) {
        createBox(at: CGPoint(x: -10, y: 400), size: CGSize(width: 20, height: 800), color: .clear)
        createBox(at: CGPoint(x: 410, y: 400), size: CGSize(width: 20, height: 800), color: .clear)
        
        f1Node = createBox(at: faucet1Pos, size: CGSize(width: 30, height: 20), color: .systemBlue); f1Node.name = "faucet1"
        f2Node = createBox(at: faucet2Pos, size: CGSize(width: 30, height: 20), color: .systemPurple); f2Node.name = "faucet2"
        f3Node = createBox(at: faucet3Pos, size: CGSize(width: 30, height: 20), color: .systemTeal); f3Node.name = "faucet3"
        f4Node = createBox(at: faucet4Pos, size: CGSize(width: 30, height: 20), color: .systemIndigo); f4Node.name = "faucet4"
        
        goalNode = createBox(at: goalPos, size: CGSize(width: 100, height: 40), color: .systemGreen)
        goalNode.name = "goal"
        goalNode.physicsBody?.categoryBitMask = PhysicsCategory.goal
        goalNode.physicsBody?.contactTestBitMask = PhysicsCategory.water
        goalNode.alpha = 0.3
    }
    
    func createGate(id: Int, type: Int, pos: CGPoint) {
        let color: UIColor = type == 1 ? .systemRed : (type == 2 ? .systemOrange : (type == 3 ? .systemYellow : .systemPurple))
        let body = createBox(at: pos, size: CGSize(width: 140, height: 80), color: color)
        body.name = "machine_\(id)"
        
        let outPos = CGPoint(x: pos.x, y: pos.y - 60)
        createBox(at: outPos, size: CGSize(width: 20, height: 40), color: .gray)
        
        let sA = createBackgroundSensor(at: type == 3 ? CGPoint(x: pos.x, y: pos.y + 65) : CGPoint(x: pos.x - 70, y: pos.y + 65), size: type == 3 ? CGSize(width: 60, height: 40) : CGSize(width: 40, height: 40), color: .systemBlue)
        let sB = createBackgroundSensor(at: type == 3 ? CGPoint(x: -100, y: -100) : CGPoint(x: pos.x + 70, y: pos.y + 65), size: type == 3 ? CGSize(width: 1, height: 1) : CGSize(width: 40, height: 40), color: .systemPurple)
        
        let gate = LogicGate(id: id, type: type, body: body, sensorA: sA, sensorB: sB, outputPos: outPos)
        gates.append(gate)
    }
    
    @discardableResult
    func createPlatform(at pos: CGPoint, width: CGFloat, angle: CGFloat) -> SKSpriteNode {
        let plat = createBox(at: pos, size: CGSize(width: width, height: 16), color: .darkGray)
        plat.name = "customWall"
        plat.zRotation = angle
        plat.physicsBody?.friction = 0.1
        return plat
    }
    
    @discardableResult
    func createBox(at pos: CGPoint, size: CGSize, color: UIColor) -> SKSpriteNode {
        let box = SKSpriteNode(color: color, size: size)
        box.position = pos
        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody?.isDynamic = false
        box.physicsBody?.categoryBitMask = PhysicsCategory.wall
        addChild(box)
        return box
    }
    
    func createBackgroundSensor(at pos: CGPoint, size: CGSize, color: UIColor) -> SKSpriteNode {
        let sensor = SKSpriteNode(color: color.withAlphaComponent(0.3), size: size)
        sensor.position = pos
        sensor.zPosition = -1
        addChild(sensor)
        return sensor
    }
    
    // nice little helper to add text hints to the background
    func addHint(text: String, pos: CGPoint) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 14
        label.fontColor = UIColor.white.withAlphaComponent(0.6)
        label.position = pos
        label.zPosition = -5
        addChild(label)
        tutorialLabels.append(label)
    }
}
