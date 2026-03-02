import SwiftUI

struct Card: Identifiable {
    let id = UUID()
    let content: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
    var position: CGFloat = 0
}