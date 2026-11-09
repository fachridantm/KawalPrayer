import SwiftUI

struct DynamicIslandView: View {

    let alert: DynamicIslandAlert
    let anchorSize: CGSize
    let onDismiss: () -> Void

    @State private var isExpanded = false
    @State private var isPulsing = false

    private var islandShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: OX.Radius.None,
            bottomLeadingRadius: OX.Radius.XL2,
            bottomTrailingRadius: OX.Radius.XL2,
            topTrailingRadius: OX.Radius.None
        )
    }

    var body: some View {
        VStack(spacing: OX.Spacing.None) {
            content
                .frame(
                    width: isExpanded ? DimensToken.ISLAND_WIDTH : anchorSize.width,
                    height: isExpanded ? DimensToken.ISLAND_HEIGHT : anchorSize.height,
                    alignment: .top
                )
                .background(Color.black)
                .clipShape(islandShape)
                .shadow(
                    color: Color.black.opacity(FloatToken.PERCENT_50),
                    radius: OX.Spacing.L
                )
            Spacer(minLength: OX.Spacing.None)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                isExpanded = true
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if isExpanded {
            VStack(spacing: OX.Spacing.S) {
                // Header row hugs the notch: icon on the left, accent divider on the right
                HStack {
                    Image(systemName: alert.kind.icon)
                        .foregroundStyle(alert.kind.accent)
                        .opacity(isPulsing ? FloatToken.PERCENT_100 : FloatToken.PERCENT_50)
                    Spacer()
                    Text(alert.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                }
                .frame(height: max(anchorSize.height, DimensToken.SIZE_32))

                Text(alert.body)
                    .font(.system(size: DimensToken.SIZE_15, weight: .medium))
                    .foregroundStyle(Color.white)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                HStack(spacing: OX.Spacing.S) {
                    if let actionTitle = alert.actionTitle {
                        Button(actionTitle) {
                            alert.onAction?()
                            onDismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(alert.kind.accent)
                    }
                    Button(alert.dismissTitle) {
                        onDismiss()
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.white)
                }
                .controlSize(.small)
            }
            .padding(.horizontal, OX.Spacing.XL)
            .padding(.bottom, OX.Spacing.M)
            .transition(.opacity)
        } else {
            Color.clear
        }
    }
}
