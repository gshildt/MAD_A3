import SwiftUI

struct CardView: View {
    @ObservedObject var viewModel: CardGameViewModel
    let card: Card
    
    @State private var dragAmount: CGSize = .zero
    @State private var flipRotation: Double = 0   // drives the polished flip
    
    var body: some View {
        ZStack {
            back
                .opacity(flipRotation <= 90 ? 1 : 0)
            front
                .opacity(flipRotation > 90 ? 1 : 0)
        }
        .rotation3DEffect(.degrees(flipRotation),
                          axis: (x: 0, y: 1, z: 0))
        .offset(dragAmount)
        .gesture(dragGesture)
        .onTapGesture(count: 2) {
            flipCard()
        }
        .opacity(card.isMatched ? 0.4 : 1.0)
    }
    
    private func flipCard() {
        withAnimation(.easeInOut(duration: 0.45)) {
            flipRotation += 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.23) {
            viewModel.selectCard(card)
        }
    }
    
    private var front: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white)
            .shadow(radius: 3)
            .overlay(
                Text(card.content)
                    .font(.largeTitle)
            )
    }
    
    private var back: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.blue)
            .overlay(
                Stripes()
                    .stroke(Color.white.opacity(0.4), lineWidth: 2)
            )
            .shadow(radius: 3)
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragAmount = value.translation
            }
            .onEnded { _ in
                withAnimation(.spring()) {
                    dragAmount = .zero
                }
            }
    }
}
