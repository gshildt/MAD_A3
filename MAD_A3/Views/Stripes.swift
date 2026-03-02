import SwiftUI

struct Stripes: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stripeWidth: CGFloat = 10
        
        for x in stride(from: 0, through: rect.width, by: stripeWidth * 2) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x + stripeWidth, y: rect.height))
        }
        
        return path
    }
}