import SwiftUI

struct MainGameView: View {
    @StateObject private var gameViewModel = CardGameViewModel()
    
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            
            ZStack {
                Color(red: 0.8, green: 0.9, blue: 1.0)
                    .ignoresSafeArea()
                
                if isLandscape {
                    HStack {
                        cardGrid(size: geo.size, isLandscape: true, viewModel: gameViewModel)
                        ControlPanel(viewModel: gameViewModel)
                            .frame(width: geo.size.width * 0.3)
                            .padding()
                    }
                } else {
                    VStack {
                        cardGrid(size: geo.size, isLandscape: false, viewModel: gameViewModel)
                        ControlPanel(viewModel: gameViewModel)
                            .padding()
                    }
                }
            }
            .animation(.spring(), value: isLandscape)
        }
    }
    
    private func cardGrid(size: CGSize, isLandscape: Bool, viewModel: CardGameViewModel) -> some View {
        let minWidth: CGFloat = isLandscape ? 100 : 80
        
        let columns = [
            GridItem(.adaptive(minimum: minWidth), spacing: 10)
        ]
        
        return ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.cards.indices, id: \.self) { index in
                    CardView(card: .constant(viewModel.cards[index]), viewModel: gameViewModel)
                }
            }
            .padding()
        }
    }
}

