// Stripes.swift
// Stripes.swift

import SwiftUI

/// A simple diagonal stripes shape used as an overlay on card backs.
/// The shape draws a repeating diagonal stripe pattern across the provided rect.
public struct Stripes: Shape {
    /// Stripe width in points
    public var stripeWidth: CGFloat = 8
    /// Spacing between stripes
    public var spacing: CGFloat = 8
    /// Angle of stripes in degrees (default 45)
    public var angle: Angle = .degrees(45)

    public init(stripeWidth: CGFloat = 8, spacing: CGFloat = 8, angle: Angle = .degrees(45)) {
        self.stripeWidth = stripeWidth
        self.spacing = spacing
        self.angle = angle
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()

        // Create stripes by drawing rectangles along a long band that covers the rotated rect.
        // Compute a bounding length that covers the diagonal.
        let diagonal = sqrt(rect.width * rect.width + rect.height * rect.height)
        // We'll draw stripes along the x-axis of a larger rect and then rotate/translate them into place.
        let bandRect = CGRect(x: -diagonal, y: -diagonal, width: diagonal * 3, height: diagonal * 3)

        // Number of stripes needed
        let step = stripeWidth + spacing
        let count = Int((bandRect.width / step).rounded(.up)) + 2

        for i in 0..<count {
            let x = bandRect.minX + CGFloat(i) * step
            let stripe = CGRect(x: x, y: bandRect.minY, width: stripeWidth, height: bandRect.height)
            path.addRect(stripe)
        }

        // Rotate the stripe pattern around the center of the original rect
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var transform = CGAffineTransform(translationX: center.x, y: center.y)
        transform = transform.rotated(by: CGFloat(angle.radians))
        transform = transform.translatedBy(x: -bandRect.midX, y: -bandRect.midY)

        return path.applying(transform)
    }
}