import SpriteKit
import CoreMotion

// our custom logic gate object
class LogicGate {
    var id: Int
    var type: Int // 1=AND, 2=OR, 3=NOT, 4=XOR
    var body: SKSpriteNode
    var sensorA: SKSpriteNode
    var sensorB: SKSpriteNode
    var outputPos: CGPoint
    
    var recentHitsA: [TimeInterval] = []
    var recentHitsB: [TimeInterval] = []
    var sustainedTimeA: TimeInterval = 0.0
    var sustainedTimeB: TimeInterval = 0.0
    
    var isActive = false
    var stateTimer: TimeInterval = 0.0
    var lastSpawnTime: TimeInterval = 0.0
    
    init(id: Int, type: Int, body: SKSpriteNode, sensorA: SKSpriteNode, sensorB: SKSpriteNode, outputPos: CGPoint) {
        self.id = id
        self.type = type
        self.body = body
        self.sensorA = sensorA
        self.sensorB = sensorB
        self.outputPos = outputPos
        
        // slap a nice label right on the machine so we know what it does
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.fontSize = 24
        label.verticalAlignmentMode = .center
        label.zPosition = 5
        
        if type == 1 { label.text = "AND" }
        else if type == 2 { label.text = "OR" }
        else if type == 3 { label.text = "NOT" }
        else if type == 4 { label.text = "XOR" }
        
        body.addChild(label)
    }
}

class LiquidScene: SKScene, SKPhysicsContactDelegate {
    
    var onWin: (() -> Void)?
    var currentLevel: Int = 1
    
    var isGameActive = true
    var waterNodeLayer = SKNode()
    
    var isEditingMode = false
    var editorTool = "move"
    var draggedNode: SKNode?
    var drawStartPos: CGPoint?
    var drawPreviewNode: SKSpriteNode?
    
    let motionManager = CMMotionManager()
    var isGravityLocked = true 
    
    var isF1On = false, isF2On = false, isF3On = false, isF4On = false
    var faucet1Pos = CGPoint(x: 50, y: 750)
    var faucet2Pos = CGPoint(x: 150, y: 750)
    var faucet3Pos = CGPoint(x: 250, y: 750)
    var faucet4Pos = CGPoint(x: 350, y: 750)
    var f1Node: SKSpriteNode!, f2Node: SKSpriteNode!, f3Node: SKSpriteNode!, f4Node: SKSpriteNode!
    var lastSpawnTime: TimeInterval = 0
    
    var gates: [LogicGate] = []
    var tutorialLabels: [SKLabelNode] = []
    
    var goalNode: SKSpriteNode!
    var goalContactDuration: TimeInterval = 0.0
    var currentTimeAcc: TimeInterval = 0 
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -8.0)
        
        // set up the nice background image if they added it to the project
        let bg = SKSpriteNode(imageNamed: "background")
        bg.position = CGPoint(x: size.width/2, y: size.height/2)
        bg.zPosition = -10
        bg.alpha = 0.4
        // fallback color if image doesn't exist
        self.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1)
        addChild(bg)
        
        addChild(waterNodeLayer)
        
        if motionManager.isDeviceMotionAvailable { motionManager.startDeviceMotionUpdates() }
        buildLevel()
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameActive else { return }
        if isEditingMode { waterNodeLayer.removeAllChildren(); return }
        
        if self.currentTimeAcc == 0 { self.currentTimeAcc = currentTime }
        let deltaTime = currentTime - self.currentTimeAcc
        self.currentTimeAcc = currentTime
        
        // gravity processing
        if !isGravityLocked, let data = motionManager.deviceMotion {
            let angle = atan2(CGFloat(data.gravity.y), CGFloat(data.gravity.x))
            let snappedAngle = round(angle / (.pi / 4.0)) * (.pi / 4.0)
            physicsWorld.gravity = CGVector(dx: cos(snappedAngle) * 8.0, dy: sin(snappedAngle) * 8.0)
        }
        
        // spawn water from active faucets
        if currentTime - lastSpawnTime > 0.033 {
            if isF1On { spawnWaterParticle(at: faucet1Pos, applyJitter: true) }
            if isF2On { spawnWaterParticle(at: faucet2Pos, applyJitter: true) }
            if isF3On { spawnWaterParticle(at: faucet3Pos, applyJitter: true) }
            if isF4On { spawnWaterParticle(at: faucet4Pos, applyJitter: true) }
            lastSpawnTime = currentTime
        }
        
        var dropsRemoved = 0
        var isGoalHitThisFrame = false
        
        // iterate over all water drops to handle logic
        for node in waterNodeLayer.children {
            // cull nodes off screen
            if node.position.y < -50 || node.position.y > 850 || node.position.x < -50 || node.position.x > 450 {
                node.removeFromParent()
                continue
            }
            if goalNode.intersects(node) { isGoalHitThisFrame = true }
            
            // let the gates consume water drops if they hit a sensor
            var nodeConsumed = false
            for gate in gates {
                if gate.sensorA.intersects(node) {
                    node.removeFromParent()
                    gate.recentHitsA.append(currentTime)
                    gate.sensorA.color = UIColor.systemBlue.withAlphaComponent(0.8)
                    nodeConsumed = true; break
                }
                if gate.type != 3 && gate.sensorB.intersects(node) {
                    node.removeFromParent()
                    gate.recentHitsB.append(currentTime)
                    gate.sensorB.color = UIColor.systemPurple.withAlphaComponent(0.8)
                    nodeConsumed = true; break
                }
            }
            if nodeConsumed { continue }
            
            // delete drops that have been sitting still too long
            guard let body = node.physicsBody else { continue }
            if abs(body.velocity.dx) < 3.0 && abs(body.velocity.dy) < 3.0 {
                var statTime = node.userData?["stationaryTime"] as? TimeInterval ?? 0.0
                statTime += deltaTime
                if statTime > 1.5 {
                    node.run(SKAction.sequence([SKAction.scale(to: 0, duration: 0.2), SKAction.removeFromParent()]))
                } else { node.userData?["stationaryTime"] = statTime }
            } else { node.userData?["stationaryTime"] = 0.0 }
            
            // keep the node count under 300 so the device doesn't lag
            if dropsRemoved < (waterNodeLayer.children.count - 300) { node.removeFromParent(); dropsRemoved += 1 }
        }
        
        // handles the 2 second glow to win
        if isGoalHitThisFrame {
            goalContactDuration += deltaTime
            if goalContactDuration >= 2.0 && isGameActive { isGameActive = false; onWin?() }
        } else { goalContactDuration = max(0, goalContactDuration - deltaTime) }
        goalNode.alpha = 0.3 + CGFloat(min(1.0, goalContactDuration / 2.0) * 0.7)
        
        // process all the internal state machines for the logic gates
        for gate in gates {
            gate.recentHitsA.removeAll(where: { currentTime - $0 > 0.3 })
            gate.recentHitsB.removeAll(where: { currentTime - $0 > 0.3 })
            
            if gate.recentHitsA.count >= 3 { gate.sustainedTimeA += deltaTime } else { gate.sustainedTimeA = 0.0 }
            if gate.recentHitsB.count >= 3 { gate.sustainedTimeB += deltaTime } else { gate.sustainedTimeB = 0.0 }
            
            let hasA = gate.sustainedTimeA >= 0.5
            let hasB = gate.sustainedTimeB >= 0.5
            
            var conditionMet = false
            if gate.type == 1 { conditionMet = hasA && hasB }
            else if gate.type == 2 { conditionMet = hasA || hasB }
            else if gate.type == 3 { conditionMet = !hasA }
            else if gate.type == 4 { conditionMet = (hasA != hasB) }
            
            if conditionMet != gate.isActive {
                gate.stateTimer += deltaTime
                if gate.stateTimer >= 0.5 { gate.isActive = conditionMet; gate.stateTimer = 0.0 }
            } else { gate.stateTimer = 0.0 }
            
            // spit out water if the gate is active
            if currentTime - gate.lastSpawnTime > 0.033 {
                gate.lastSpawnTime = currentTime
                if gate.isActive { spawnWaterParticle(at: gate.outputPos, applyJitter: false, initialVelocity: CGVector(dx: 0, dy: -30)) }
            }
            
            // visual gate coloring based on state
            if gate.type == 1 { gate.body.color = gate.isActive ? .systemGreen : .systemRed }
            else if gate.type == 2 { gate.body.color = gate.isActive ? .systemGreen : .systemOrange }
            else if gate.type == 3 { gate.body.color = gate.isActive ? .systemGreen : .systemRed }
            else if gate.type == 4 {
                if gate.isActive { gate.body.color = .systemGreen }
                else if hasA && hasB { gate.body.color = .systemRed }
                else { gate.body.color = .systemPurple }
            }
            
            // dim the sensors if water isn't hitting them
            if gate.recentHitsA.count < 3 { gate.sensorA.color = UIColor.systemBlue.withAlphaComponent(0.3) }
            if gate.type != 3 && gate.recentHitsB.count < 3 { gate.sensorB.color = UIColor.systemPurple.withAlphaComponent(0.3) }
        }
    }
}
