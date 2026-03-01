import SwiftUI
import SpriteKit

struct LiquidLogicView: UIViewControllerRepresentable {
    @Binding var hasWon: Bool
    @Binding var isF1On: Bool
    @Binding var isF2On: Bool
    @Binding var isF3On: Bool
    @Binding var isF4On: Bool
    @Binding var isGravityLocked: Bool
    @Binding var isEditingMode: Bool
    @Binding var editorTool: String
    var currentLevel: Int
    
    func makeUIViewController(context: Context) -> LiquidLogicViewController {
        let vc = LiquidLogicViewController()
        vc.currentLevel = currentLevel
        vc.onWin = { DispatchQueue.main.async { self.hasWon = true } }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: LiquidLogicViewController, context: Context) {
        uiViewController.gameScene?.isF1On = isF1On
        uiViewController.gameScene?.isF2On = isF2On
        uiViewController.gameScene?.isF3On = isF3On
        uiViewController.gameScene?.isF4On = isF4On
        uiViewController.gameScene?.isGravityLocked = isGravityLocked
        uiViewController.gameScene?.isEditingMode = isEditingMode
        uiViewController.gameScene?.editorTool = editorTool
    }
}

class LiquidLogicViewController: UIViewController {
    var skView: SKView!
    var gameScene: LiquidScene!
    var onWin: (() -> Void)?
    var currentLevel: Int = 1
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
    override var shouldAutorotate: Bool { return false }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black 
        
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        skView.backgroundColor = .black
        view.addSubview(skView)
        
        gameScene = LiquidScene(size: CGSize(width: 400, height: 800))
        gameScene.scaleMode = .aspectFit
        gameScene.currentLevel = currentLevel
        gameScene.onWin = { [weak self] in self?.onWin?() }
        
        skView.presentScene(gameScene)
    }
}
