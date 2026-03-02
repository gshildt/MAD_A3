// Card.swift
// Card.swift

import Foundation
import SwiftUI

/// Model representing a single memory game card.
public struct Card: Identifiable, Equatable {
    /// Unique identifier for the card
    public let id: UUID
    /// Whether the card is currently face up
    public var isFaceUp: Bool = false
    /// Whether the card has been matched and removed from play
    public var isMatched: Bool = false
    /// The visible content of the card (emoji)
    public let content: String
    /// A transient position used for drag animations (not persisted)
    public var position: CGFloat = 0.0

    /// Default initializer
    public init(id: UUID = UUID(), isFaceUp: Bool = false, isMatched: Bool = false, content: String, position: CGFloat = 0.0) {
        self.id = id
        self.isFaceUp = isFaceUp
        self.isMatched = isMatched
        self.content = content
        self.position = position
    }

    /// Equatable conformance: two cards are equal when their ids match.
    public static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.id == rhs.id
    }
}