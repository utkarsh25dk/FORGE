import SwiftUI

struct AuthContainerView: View {
    @Environment(\.forge) private var forge
    @State private var showSignUp = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: Space.sm) {
                Text("FORGE")
                    .font(.forgeDisplay(40))
                    .foregroundStyle(forge.textPrimary)
                Text("Every rep feeds the fire.")
                    .font(.forgeBody(15))
                    .foregroundStyle(forge.textSecondary)
            }
            .padding(.top, Space.xxl)
            .padding(.bottom, Space.xl)

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
