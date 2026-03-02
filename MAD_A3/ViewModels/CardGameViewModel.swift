import SwiftUI
internal import Combine

class CardGameViewModel: ObservableObject {

    @Published var cards: [Card] = []
    @Published var score: Int = 0
    @Published var moves: Int = 0
    @Published var gameOver: Bool = false
    
    private var firstSelectedIndex: Int? = nil
    
    private let emojis = ["🐶","🐱","🐸","🐵","🐼","🐷","🦊","🐰"]
    
    init() {
        startNewGame()
    }
    
    func startNewGame() {
        score = 0
        moves = 0
        gameOver = false
        firstSelectedIndex = nil
        
        var newCards: [Card] = []
        for emoji in emojis {
            newCards.append(Card(content: emoji))
            newCards.append(Card(content: emoji))
        }
        cards = newCards.shuffled()
    }
    
    func shuffleCards() {
        cards.shuffle()
    }
    
    func selectCard(_ selectedCard: Card) {
        guard let index = cards.firstIndex(where: { $0.id == selectedCard.id }) else { return }
        guard !cards[index].isMatched, !cards[index].isFaceUp else { return }
        
        cards[index].isFaceUp = true
        
        if let firstIndex = firstSelectedIndex {
            moves += 1
            
            if cards[firstIndex].content == cards[index].content {
                cards[firstIndex].isMatched = true
                cards[index].isMatched = true
                score += 2
                
                if cards.allSatisfy({ $0.isMatched }) {
                    gameOver = true
                }
            } else {
                if score > 0 { score -= 1 }
                
                let first = firstIndex
                let second = index
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.cards[first].isFaceUp = false
                    self.cards[second].isFaceUp = false
                }
            }
            
            firstSelectedIndex = nil
        } else {
            for i in cards.indices where !cards[i].isMatched {
                cards[i].isFaceUp = false
            }
            firstSelectedIndex = index
        }
    }
}
