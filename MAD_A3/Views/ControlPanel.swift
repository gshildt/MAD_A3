import SwiftUI

struct ControlPanel: View {
    @ObservedObject var gameViewModel: CardGameViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Score: \(gameViewModel.score)").font(.headline)
                Spacer()
                Text("Moves: \(gameViewModel.moves)").font(.headline)
            }
            
            HStack {
                Button("New Game") {
                    withAnimation(.spring()) {
                        gameViewModel.startNewGame()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Shuffle") {
                    withAnimation(.spring()) {
                        gameViewModel.shuffleCards()
                    }
                }
                .buttonStyle(.bordered)
            }
            
            if gameViewModel.gameOver {
                Text("Game Over!")
                    .font(.title)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}