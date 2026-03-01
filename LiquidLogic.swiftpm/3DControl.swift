import SwiftUI
import SceneKit
import CoreMotion

// wraps our 3d scene so swiftui can use it
struct Menu3DView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Menu3DViewController {
        return Menu3DViewController()
    }
    func updateUIViewController(_ uiViewController: Menu3DViewController, context: Context) {}
}

class Menu3DViewController: UIViewController {
    var sceneView: SCNView!
    var scene: SCNScene!
    var cameraNode: SCNNode!
    
    // motion manager to read the device tilt
    let motionManager = CMMotionManager()
    var particleTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = SCNView(frame: view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.backgroundColor = .black
        view.addSubview(sceneView)
        
        scene = SCNScene()
        sceneView.scene = scene
        
        // set up a camera
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 5, 20)
        scene.rootNode.addChildNode(cameraNode)
        
        setupLights()
        setupGlassBox()
        
        // gravity pulling down
        scene.physicsWorld.gravity = SCNVector3(0, -15, 0)
        
        // start dropping water randomly
        particleTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.dropWater()
        }
        
        // start reading the gyro so we can tilt the camera
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                guard let data = motion else { return }
                
                // subtly pan the camera based on how you tilt the phone
                let pitch = data.attitude.pitch
                let roll = data.attitude.roll
                self?.cameraNode.eulerAngles = SCNVector3(pitch * 0.5, roll * 0.5, 0)
            }
        }
    }
    
    deinit {
        particleTimer?.invalidate()
        motionManager.stopDeviceMotionUpdates()
    }
    
    func setupLights() {
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 500
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)
        
        let omni = SCNLight()
        omni.type = .omni
        omni.intensity = 1500
        let omniNode = SCNNode()
        omniNode.light = omni
        omniNode.position = SCNVector3(0, 10, 10)
        scene.rootNode.addChildNode(omniNode)
    }
    
    func setupGlassBox() {
        let glassMat = SCNMaterial()
        glassMat.diffuse.contents = UIColor.cyan.withAlphaComponent(0.2)
        glassMat.isDoubleSided = true
        
        // floor
        let floor = SCNNode(geometry: SCNBox(width: 20, height: 1, length: 20, chamferRadius: 0))
        floor.position = SCNVector3(0, -10, 0)
        floor.geometry?.materials = [glassMat]
        floor.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        scene.rootNode.addChildNode(floor)
    }
    
    func dropWater() {
        let sphere = SCNSphere(radius: 0.4)
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 0.9)
        mat.emission.contents = UIColor.blue.withAlphaComponent(0.5)
        sphere.materials = [mat]
        
        let node = SCNNode(geometry: sphere)
        node.position = SCNVector3(Float.random(in: -5...5), 15, Float.random(in: -5...5))
        
        let body = SCNPhysicsBody(type: .dynamic, shape: nil)
        body.restitution = 0.2
        body.friction = 0.1
        node.physicsBody = body
        
        scene.rootNode.addChildNode(node)
        
        // clean up so we don't crash
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            node.removeFromParentNode()
        }
    }
}
