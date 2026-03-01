import SwiftUI
import AVFoundation

// we keep a global player so the music doesn't restart when we switch views
var bgmPlayer: AVAudioPlayer?

func playBackgroundMusic() {
    // just looking for the music file in the bundle
    guard let url = Bundle.main.url(forResource: "bgm", withExtension: "mp3") else { return }
    do {
        bgmPlayer = try AVAudioPlayer(contentsOf: url)
        bgmPlayer?.numberOfLoops = -1 // loop forever
        bgmPlayer?.volume = 0.4
        bgmPlayer?.play()
    } catch {
        print("couldn't load music")
    }
}

struct ContentView: View {
    @State private var gameState = "menu"
    @State private var currentLevel = 1
    
    @State private var hasWon = false
    @State private var isGravityLocked = true
    @State private var isEditingMode = false
    @State private var editorTool = "move"
    
    // our 4 trusty faucets
    @State private var isF1On = false
    @State private var isF2On = false
    @State private var isF3On = false
    @State private var isF4On = false
    
    var body: some View {
        ZStack {
            if gameState == "menu" {
                // the new 3d water menu background
                Menu3DView().edgesIgnoringSafeArea(.all)
                
                // dark overlay so you can actually read the text
                Color.black.opacity(0.6).edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 30) {
                        Text("LIQUID LOGIC")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 40)
                        
                        VStack(spacing: 15) {
                            Button(action: { startGame(level: 1) }) { MenuButtonView(title: "LEVEL 1: AND", color: .red) }
                            Button(action: { startGame(level: 2) }) { MenuButtonView(title: "LEVEL 2: OR COMPLEX", color: .orange) }
                            Button(action: { startGame(level: 3) }) { MenuButtonView(title: "LEVEL 3: NOT A CHANCE", color: .yellow, textColor: .black) }
                            Button(action: { startGame(level: 4) }) { MenuButtonView(title: "LEVEL 4: XOR CHAOS", color: .purple) }
                            Button(action: { startGame(level: 5) }) { MenuButtonView(title: "LEVEL 5: GRAVITY GATES", color: .green) }
                            Button(action: { startGame(level: 6) }) { MenuButtonView(title: "LEVEL 6: EDITOR", color: .cyan, textColor: .black) }
                        }
                    }
                }
            } else {
                // the actual 2d game layer
                LiquidLogicView(
                    hasWon: $hasWon,
                    isF1On: $isF1On, isF2On: $isF2On, isF3On: $isF3On, isF4On: $isF4On,
                    isGravityLocked: $isGravityLocked,
                    isEditingMode: $isEditingMode,
                    editorTool: $editorTool,
                    currentLevel: currentLevel
                )
                .edgesIgnoringSafeArea(.all)
                
                // the top navigation bar
                VStack {
                    HStack {
                        Button(action: { returnToMenu() }) {
                            Text("🔙")
                                .font(.system(size: 18))
                                .padding()
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        Spacer()
                        
                        if currentLevel == 6 {
                            Button(action: { isEditingMode.toggle() }) {
                                Text(isEditingMode ? "▶️ TEST" : "✏️ EDIT")
                                    .font(.system(size: 14, weight: .bold))
                                    .padding()
                                    .background(isEditingMode ? Color.green : Color.cyan)
                                    .foregroundColor(isEditingMode ? .white : .black)
                                    .cornerRadius(10)
                            }
                            Spacer()
                        }
                        
                        Button(action: { isGravityLocked.toggle() }) {
                            Text(isGravityLocked ? "🔒 GRAVITY" : "🔓 GRAVITY")
                                .font(.system(size: 14, weight: .bold))
                                .padding()
                                .background(isGravityLocked ? Color.orange : Color.gray.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    if isEditingMode {
                        HStack(spacing: 8) {
                            EditorToolBtn(title: "✋ MOVE", tool: "move", selected: $editorTool)
                            EditorToolBtn(title: "🧱 WALL", tool: "wall", selected: $editorTool)
                            EditorToolBtn(title: "🗑️ ERASE", tool: "eraser", selected: $editorTool)
                            EditorToolBtn(title: "✏️ DRAW", tool: "draw", selected: $editorTool)
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 20)
                    } else {
                        // bottom faucet buttons
                        HStack(spacing: 10) {
                            FaucetBtn(title: isF1On ? "🛑 1" : "💧 1", isOn: $isF1On, onColor: .red, offColor: .blue)
                            FaucetBtn(title: isF2On ? "🛑 2" : "💧 2", isOn: $isF2On, onColor: .red, offColor: .purple)
                            FaucetBtn(title: isF3On ? "🛑 3" : "💧 3", isOn: $isF3On, onColor: .red, offColor: .teal)
                            FaucetBtn(title: isF4On ? "🛑 4" : "💧 4", isOn: $isF4On, onColor: .red, offColor: .indigo)
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 20)
                    }
                }
                
                // the win screen popup
                if hasWon {
                    VStack(spacing: 20) {
                        Text("🎉 COMPLETE! 🎉")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .green, radius: 10, x: 0, y: 0)
                        
                        Button(action: { returnToMenu() }) {
                            Text("MAIN MENU")
                                .font(.headline)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 15)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(25)
                        }
                    }
                    .padding(40)
                    .background(Color.black.opacity(0.9))
                    .cornerRadius(30)
                }
            }
        }
        .onAppear {
            if bgmPlayer == nil { playBackgroundMusic() }
        }
    }
    
    private func startGame(level: Int) {
        currentLevel = level
        isF1On = false; isF2On = false; isF3On = false; isF4On = false
        // gravity is unlocked by default only on level 5
        isGravityLocked = (level != 5) 
        isEditingMode = (level == 6)
        hasWon = false
        gameState = "playing"
    }
    
    private func returnToMenu() {
        isF1On = false; isF2On = false; isF3On = false; isF4On = false
        hasWon = false
        gameState = "menu"
    }
}

// simple ui helpers
struct MenuButtonView: View {
    let title: String
    let color: Color
    var textColor: Color = .white
    var body: some View {
        Text(title).font(.headline).padding().frame(width: 250).background(color).foregroundColor(textColor).cornerRadius(15)
    }
}

struct EditorToolBtn: View {
    let title: String
    let tool: String
    @Binding var selected: String
    var body: some View {
        Button(action: { selected = tool }) {
            Text(title).font(.system(size: 12, weight: .bold)).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 15).background(selected == tool ? Color.green : Color.gray).cornerRadius(12)
        }
    }
}

struct FaucetBtn: View {
    let title: String
    @Binding var isOn: Bool
    let onColor: Color
    let offColor: Color
    var body: some View {
        Button(action: { isOn.toggle() }) {
            Text(title).font(.system(size: 16, weight: .black)).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 15).background(isOn ? onColor : offColor).cornerRadius(12)
        }
    }
}
