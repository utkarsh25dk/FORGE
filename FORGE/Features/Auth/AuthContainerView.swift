import SwiftUI

struct AuthContainerView: View {
    @Environment(\.forge) private var forge
    @State private var showSignUp = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text("FORGE")
                    .font(.forgeDisplay(52))
                    .foregroundStyle(forge.textPrimary)
                Text("Every rep feeds the fire.")
                    .font(.forgeBody(15))
                    .foregroundStyle(forge.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Space.xl)
            .padding(.top, Space.xxl + Space.md)
            .padding(.bottom, Space.xxl)

            if showSignUp {
                SignUpView(switchToLogin: { withAnimation(.easeInOut(duration: 0.2)) { showSignUp = false } })
            } else {
                LoginView(switchToSignUp: { withAnimation(.easeInOut(duration: 0.2)) { showSignUp = true } })
            }
            Spacer()
        }
        .forgeScreenBackground()
    }
}
