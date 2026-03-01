import Foundation

struct PhysicsCategory {
    static let none: UInt32  = 0
    static let water: UInt32 = 0b1
    static let goal: UInt32  = 0b10
    static let wall: UInt32  = 0b100
}
