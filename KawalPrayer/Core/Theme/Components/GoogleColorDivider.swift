import SwiftUI

public struct GoogleColorDivider: View {

    public var height: CGFloat = DimensToken.SIZE_4

    public init(height: CGFloat = DimensToken.SIZE_4) {
        self.height = height
    }

    public init(thickness: CGFloat) {
        self.height = thickness
    }

    public var body: some View {
        HStack(spacing: 0) {
            ColorToken.Blue
                .frame(maxWidth: .infinity)
            ColorToken.Red
                .frame(maxWidth: .infinity)
            ColorToken.Yellow
                .frame(maxWidth: .infinity)
            ColorToken.Green
                .frame(maxWidth: .infinity)
        }
        .frame(height: height)
        .clipShape(Capsule())
    }
}
