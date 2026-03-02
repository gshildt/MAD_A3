// ControlPanel.swift
// ControlPanel.swift

import SwiftUI

/// Control panel showing score, moves, and action buttons.
/// Accepts an ObservedObject view model to read and trigger game actions.
public struct ControlPanel: View {
    @ObservedObject public var viewModel: CardGameViewModel
    @State private var animateButtons: Bool = false

    public init(viewModel: CardGameViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 12) {
            if viewModel.isGameOver {
                Text("Game Over!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.score)")
                        .font(.headline)
                        .bold()
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Moves")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.moves)")
                        .font(.headline)
                        .bold()
                }
            }

            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        viewModel.newGame(pairs: viewModel.defaultPairs)
                        animateButtons.toggle()
                    }
                }) {
                    Text("New Game")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.12))
                        .cornerRadius(10)
                }
                .accessibilityLabel("New Game")
                .accessibilityHint("Starts a new game with the same number of pairs.")

                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        viewModel.shuffle()
                        animateButtons.toggle()
                    }
                }) {
                    Text("Shuffle")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.12))
                        .cornerRadius(10)
                }
                .accessibilityLabel("Shuffle")
                .accessibilityHint("Shuffles the remaining cards and cancels pending flips.")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding([.horizontal])
    }
}