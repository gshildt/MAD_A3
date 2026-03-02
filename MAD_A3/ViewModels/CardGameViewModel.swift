// CardGameViewModel.swift
// CardGameViewModel.swift

import Foundation
import SwiftUI
import Combine

/// ViewModel for the memory matching game.
public final class CardGameViewModel: ObservableObject {
    // MARK: - Configurable parameters (change near top)
    /// Default number of pairs when starting a new game
    public var defaultPairs: Int = 6
    /// Delay before flipping back mismatched cards (seconds)
    public var flipBackDelay: TimeInterval = 0.8
    /// Points awarded for a match
    public var matchPoints: Int = 2
    /// Penalty for a mismatch (subtracted from score, never below 0)
    public var mismatchPenalty: Int = 1

    // MARK: - Published game state
    @Published public var cards: [Card] = []
    @Published public private(set) var score: Int = 0
    @Published public private(set) var moves: Int = 0

    // Internal state
    /// Index of the only face-up card (if exactly one is face up)
    private var indexOfOnlyFaceUpCard: Int? = nil
    /// Work item used to schedule flip-back of mismatched cards; can be cancelled
    private var flipBackWorkItem: DispatchWorkItem? = nil
    /// The emoji pool used to create pairs (constant set)
    private let emojiPool: [String] = ["🐶","🐱","🦊","🐻","🐼","🐨","🐯","🦁","🐮","🐷","🐸","🐵","🐔","🦄","🐝","🐙","🦋","🌵","🍎","🍌","🍓","🍇","🍉","🍒","⚽️","🏀","🎲","🎵","🚗","✈️","🚀","🌞","🌙"]

    // MARK: - Computed properties
    /// Whether the game is over (all pairs matched)
    public var isGameOver: Bool {
        return cards.allSatisfy { $0.isMatched }
    }

    // MARK: - Initialization
    public init(pairs: Int = 6) {
        self.defaultPairs = pairs
        newGame(pairs: pairs)
    }

    // MARK: - Public API

    /// Start a new game with the given number of pairs.
    /// Cancels any pending flip-back actions and resets score/moves.
    public func newGame(pairs: Int? = nil) {
        // Cancel any pending flip-back
        flipBackWorkItem?.cancel()
        flipBackWorkItem = nil

        let pairCount = pairs ?? defaultPairs
        defaultPairs = pairCount

        // Reset score and moves
        score = 0
        moves = 0
        indexOfOnlyFaceUpCard = nil

        // Choose emojis and create pairs
        var chosen = Array(emojiPool.prefix(pairCount))
        // If pool smaller than requested, repeat from pool start
        while chosen.count < pairCount {
            chosen.append(contentsOf: emojiPool.prefix(pairCount - chosen.count))
        }

        var newCards: [Card] = []
        for emoji in chosen {
            newCards.append(Card(content: emoji))
            newCards.append(Card(content: emoji))
        }

        // Shuffle positions
        newCards.shuffle()
        // Reset transient positions
        for i in newCards.indices {
            newCards[i].position = 0.0
        }

        // Publish
        DispatchQueue.main.async {
            self.cards = newCards
        }
    }

    /// Shuffle the current deck in place. Cancels pending flip-back.
    public func shuffle() {
        flipBackWorkItem?.cancel()
        flipBackWorkItem = nil
        indexOfOnlyFaceUpCard = nil
        // Shuffle only unmatched cards positions while preserving matched ones
        var unmatched = cards.filter { !$0.isMatched }
        unmatched.shuffle()
        var newDeck: [Card] = []
        var unmatchedIndex = 0
        for card in cards {
            if card.isMatched {
                newDeck.append(card)
            } else {
                var c = unmatched[unmatchedIndex]
                // preserve face up/down state as false when shuffling
                c.isFaceUp = false
                newDeck.append(c)
                unmatchedIndex += 1
            }
        }
        DispatchQueue.main.async {
            self.cards = newDeck
        }
    }

    /// User selects a card by its id. Handles flipping, matching, scoring, and scheduling flip-back.
    public func selectCard(cardID: UUID) {
        // Cancel any pending flip-back when user interacts (new attempt)
        flipBackWorkItem?.cancel()
        flipBackWorkItem = nil

        guard let chosenIndex = cards.firstIndex(where: { $0.id == cardID }) else { return }
        // Ignore taps on already matched cards or the same face-up card
        if cards[chosenIndex].isMatched || cards[chosenIndex].isFaceUp {
            return
        }

        // If there is exactly one face-up card already, this is the second selection
        if let potentialMatchIndex = indexOfOnlyFaceUpCard {
            // Flip the chosen card up
            cards[chosenIndex].isFaceUp = true
            // Increment moves because second card revealed
            moves += 1

            // Check for match
            if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                // Match: award points and mark matched
                score += 2 // Increase score by 2 for a match
                cards[chosenIndex].isMatched = true
                cards[potentialMatchIndex].isMatched = true
                // Reset index tracker
                indexOfOnlyFaceUpCard = nil
            } else {
                // Mismatch: apply penalty (never below 0)
                score = max(0, score - 1) // Decrease score by 1 for a mismatch

                // Schedule flip-back after delay. Use DispatchWorkItem so it can be cancelled.
                let workItem = DispatchWorkItem { [weak self] in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        // Flip both back down if they are not matched
                        if !self.cards[chosenIndex].isMatched {
                            self.cards[chosenIndex].isFaceUp = false
                        }
                        if !self.cards[potentialMatchIndex].isMatched {
                            self.cards[potentialMatchIndex].isFaceUp = false
                        }
                        self.indexOfOnlyFaceUpCard = nil
                        self.flipBackWorkItem = nil
                    }
                }
                flipBackWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + flipBackDelay, execute: workItem)
            }
        } else {
            // No other face-up card: flip this one up and record its index
            for index in cards.indices {
                // Turn all non-matched cards face down (ensures only one face-up)
                if !cards[index].isMatched {
                    cards[index].isFaceUp = false
                }
            }
            cards[chosenIndex].isFaceUp = true
            indexOfOnlyFaceUpCard = chosenIndex
        }
    }

    /// Updates a specific card in the cards array.
    public func updateCard(at index: Int, with card: Card) {
        guard cards.indices.contains(index) else { return }
        cards[index] = card
    }
}
