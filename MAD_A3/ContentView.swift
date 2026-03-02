// ContentView.swift
// ContentView.swift

import SwiftUI

/// Main content view composing the grid of cards and the control panel.
/// Uses GeometryReader to detect orientation and compute adaptive columns that preserve a 2:3 aspect ratio.
public struct ContentView: View {
    @StateObject private var viewModel = CardGameViewModel()
    @Namespace private var namespace

    public init() {}

    public var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let columns = 4 // Always use 3 columns for a 3x4 array
            let spacing: CGFloat = isLandscape ? 8 : 12 // Compress spacing in landscape mode
            let gridColumns = Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns)
            let cardSize: CGSize = CGSize(width: 80, height: 120) // Set a fixed card size of 40x60 for all orientations

            ZStack {
                Color(.systemBlue).opacity(0.12)
                    .ignoresSafeArea()

                if isLandscape {
                    HStack(spacing: 12) {
                        cardGrid(columns: gridColumns, spacing: spacing)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        ControlPanel(viewModel: viewModel)
                            .frame(width: geometry.size.width * 0.32)
                            .padding(.vertical)
                    }
                    .padding()
                } else {
                    VStack(spacing: 12) {
                        cardGrid(columns: gridColumns, spacing: spacing)
                        ControlPanel(viewModel: viewModel)
                            .padding(.bottom)
                    }
                    .padding()
                }
            }
        }
    }

    /// Builds the LazyVGrid of cards using the provided columns.
    private func cardGrid(columns: [GridItem], spacing: CGFloat) -> some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(viewModel.cards.indices, id: \.self) { index in
                CardView(
                    card: Binding(
                        get: { viewModel.cards[index] },
                        set: { newValue in viewModel.updateCard(at: index, with: newValue) }
                    ),
                    viewModel: viewModel
                )
                    .aspectRatio(2/3, contentMode: .fit)
                    .frame(width: 80, height: 120) // Apply fixed card size
                    .animation(.spring(), value: viewModel.cards[index].isMatched)
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

