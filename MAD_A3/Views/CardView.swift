// CardView.swift
// CardView.swift

import SwiftUI

/// View representing a single card. Accepts a Binding<Card> so it can mutate the card state in the parent array.
/// Also accepts an ObservedObject reference to the view model to trigger game actions.
public struct CardView: View {
    @Binding public var card: Card
    @ObservedObject public var viewModel: CardGameViewModel

    // Local gesture state
    @State private var dragOffset: CGSize = .zero
    @State private var rotationAngle: Angle = .zero
    @State private var flipRotation: Double = 0 // used for 3D flip animation

    // Namespace for matched animations (optional)
    @Namespace private var animationNamespace

    // Animation constants
    private let flipDuration: Double = 0.28

    public init(card: Binding<Card>, viewModel: CardGameViewModel) {
        self._card = card
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            // Card back and front are layered and their visibility is controlled by 3D rotation and opacity.
            cardBack
                .opacity(card.isFaceUp ? 0.0 : 1.0)
                .rotation3DEffect(.degrees(flipRotation), axis: (x: 0, y: 1, z: 0))
            cardFront
                .opacity(card.isFaceUp ? 1.0 : 0.0)
                .rotation3DEffect(.degrees(flipRotation - 180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(2/3, contentMode: .fit)
        .scaleEffect(card.isMatched ? 0.98 : 1.0)
        .opacity(card.isMatched ? 0.4 : 1.0)
        .shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 2)
        .rotationEffect(rotationAngle)
        .offset(dragOffset)
        .onChange(of: card.isFaceUp) { newValue in
            // Animate flip rotation when face-up state changes
            withAnimation(.linear(duration: flipDuration)) {
                flipRotation = newValue ? 180 : 0
            }
        }
        .onAppear {
            // Ensure rotation matches initial state
            flipRotation = card.isFaceUp ? 180 : 0
        }
        // Double-tap flips the card by informing the view model (game logic lives there)
        .onTapGesture(count: 2) {
            withAnimation(.spring()) {
                viewModel.selectCard(cardID: card.id)
            }
        }
        // Drag gesture: move card while dragging and snap back on release with spring animation
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { _ in
                    withAnimation(.spring()) {
                        dragOffset = .zero
                    }
                }
        )
        // Rotation gesture: purely visual rotation
        .gesture(
            RotationGesture()
                .onChanged { angle in
                    rotationAngle = angle
                }
                .onEnded { _ in
                    // Keep the rotation visually (no game logic change)
                }
        )
        // Accessibility
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }

    // MARK: - Subviews

    /// Front side of the card (white with emoji)
    private var cardFront: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
            Text(card.content)
                .font(.largeTitle)
        }
        .padding(6)
    }

    /// Back side of the card (blue gradient with diagonal stripes)
    private var cardBack: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing))
            // Stripes overlay
            Stripes(stripeWidth: 8, spacing: 8, angle: .degrees(45))
                .stroke(Color.white.opacity(0.18), lineWidth: 6)
                .blendMode(.overlay)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            // subtle pattern highlight
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        }
        .padding(6)
    }

    // MARK: - Accessibility helpers

    private var accessibilityLabel: Text {
        let contentText = Text(card.content)
        let faceState = card.isFaceUp ? "face up" : "face down"
        let matchedState = card.isMatched ? ", matched" : ", not matched"
        return contentText + Text(", \(faceState)\(matchedState)")
    }

    private var accessibilityHint: Text {
        if card.isMatched {
            return Text("This card is matched and out of play.")
        } else if card.isFaceUp {
            return Text("Double tap to flip another card.")
        } else {
            return Text("Double tap to reveal this card.")
        }
    }
}