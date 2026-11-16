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
                .overlay(
                    islandShape
                        .stroke(
                            Color.white.opacity(FloatToken.PERCENT_15),
                            lineWidth: OX.Border.WIDTH_1
                        )
                )
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
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                isExpanded = true
            }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if isExpanded {
            VStack(
                alignment: .leading,
                spacing: OX.Spacing.M
            ) {
                headerRow

                Text(alert.body)
                    .font(.system(size: DimensToken.SIZE_14, weight: .medium))
                    .foregroundStyle(Color.white.opacity(FloatToken.PERCENT_90))
                    .lineLimit(2)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                Spacer(minLength: OX.Spacing.None)

                actionRow
            }
            .padding(.horizontal, OX.Spacing.L)
            .padding(.top, OX.Spacing.S)
            .padding(.bottom, OX.Spacing.M)
            .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .top)))
        } else {
            Color.clear
        }
    }

    private var headerRow: some View {
        HStack(
            alignment: .center,
            spacing: OX.Spacing.S
        ) {
            ZStack {
                Circle()
                    .fill(alert.kind.accent.opacity(FloatToken.PERCENT_15))
                    .frame(
                        width: DimensToken.SIZE_28,
                        height: DimensToken.SIZE_28
                    )
                    .scaleEffect(isPulsing ? 1.08 : 0.95)

                Image(systemName: alert.kind.icon)
                    .font(.system(size: DimensToken.SIZE_13, weight: .semibold))
                    .foregroundStyle(alert.kind.accent)
            }

            Spacer()

            HStack(
                alignment: .center,
                spacing: OX.Spacing.XS
            ) {
                Circle()
                    .fill(alert.kind.accent)
                    .frame(
                        width: OX.Spacing.XS,
                        height: OX.Spacing.XS
                    )
                    .opacity(isPulsing ? FloatToken.PERCENT_100 : FloatToken.PERCENT_30)

                Text(alert.title)
                    .font(.system(size: DimensToken.SIZE_13, weight: .semibold))
                    .foregroundStyle(Color.white)
            }
        }
        .frame(height: max(anchorSize.height, DimensToken.SIZE_32))
    }

    private var actionRow: some View {
        HStack(spacing: OX.Spacing.S) {
            if let actionTitle = alert.actionTitle {
                Button {
                    alert.onAction?()
                    onDismiss()
                } label: {
                    Text(actionTitle)
                        .font(.system(size: DimensToken.SIZE_12, weight: .semibold))
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, OX.Spacing.XS)
                        .background(alert.kind.accent)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            Button {
                onDismiss()
            } label: {
                Text(alert.dismissTitle)
                    .font(.system(size: DimensToken.SIZE_12, weight: .medium))
                    .foregroundStyle(Color.white.opacity(FloatToken.PERCENT_85))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, OX.Spacing.XS)
                    .background(Color.white.opacity(FloatToken.PERCENT_10))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}
