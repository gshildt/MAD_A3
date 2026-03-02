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
                        cardGrid(size: geo.size, isLandscape: true)
                        ControlPanel(gameViewModel: gameViewModel)
                            .frame(width: geo.size.width * 0.3)
                            .padding()
                    }
                } else {
                    VStack {
                        cardGrid(size: geo.size, isLandscape: false)
                        ControlPanel(gameViewModel: gameViewModel)
                            .padding()
                    }
                }
            }
            .animation(.spring(), value: isLandscape)
        }
    }
    
    private func cardGrid(size: CGSize, isLandscape: Bool) -> some View {
        let minWidth: CGFloat = isLandscape ? 100 : 80
        
        let columns = [
            GridItem(.adaptive(minimum: minWidth), spacing: 10)
        ]
        
        return ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(gameViewModel.cards) { card in
                    CardView(viewModel: gameViewModel, card: card)
                        .aspectRatio(2/3, contentMode: .fit)
                        .padding(4)
                }
            }
            .padding()
        }
    }
}