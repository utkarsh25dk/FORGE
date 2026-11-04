import SwiftUI

struct AuthContainerView: View {
    @Environment(\.forge) private var forge
    @State private var showSignUp = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("FORGE")
                    .font(.forgeCaption(12))
                    .tracking(3)
                    .foregroundStyle(forge.textTertiary)

                // The headline says which screen you are on; the wordmark is just a mark.
                // Both modes used to open with FORGE over the same tagline, so logging in
                // and signing up were identical until you counted the fields.
                Text(showSignUp ? "Create your account" : "Welcome back")
                    .font(.forgeDisplay(40))
                    .foregroundStyle(forge.textPrimary)
                    .padding(.top, Space.md)

                Text(showSignUp ? "A name, an email, and you're training." : "Pick up where you left off.")
                    .font(.forgeBody(16))
                    .foregroundStyle(forge.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Space.xs)

                Group {
                    if showSignUp {
                        SignUpView(switchToLogin: { withAnimation(.easeInOut(duration: 0.2)) { showSignUp = false } })
                    } else {
                        LoginView(switchToSignUp: { withAnimation(.easeInOut(duration: 0.2)) { showSignUp = true } })
                    }
                }
                .padding(.top, Space.xxl)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Space.xl)
            .padding(.top, Space.xxl + Space.xl)
            .padding(.bottom, Space.xxl)
        }
        // Sign up stacks four fields, two toggles, a button and a link. Without a scroll
        // view the keyboard could cover the button with no way to reach it.
        .scrollDismissesKeyboard(.interactively)
        .forgeScreenBackground()
    }
}

/// Remember-me and its Face ID follow-up. Both auth screens need it, and both used to
/// carry their own copy — two places to remember when one of them changes.
struct AuthPersistenceOptions: View {
    @Environment(\.forge) private var forge
    @Binding var rememberMe: Bool
    @Binding var enableFaceID: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            Toggle(isOn: $rememberMe) {
                Text("Remember me").font(.forgeBodyMedium(14)).foregroundStyle(forge.textSecondary)
            }
            if rememberMe {
                Toggle(isOn: $enableFaceID) {
                    Label("Unlock with Face ID", systemImage: "faceid")
                        .font(.forgeBodyMedium(14))
                        .foregroundStyle(forge.textSecondary)
                }
                .transition(.opacity)
            }
        }
        .tint(forge.accent)
    }
}

/// The question is not the thing you tap, so only the answer carries the accent.
struct AuthSwitchLink: View {
    @Environment(\.forge) private var forge
    var question: String
    var action: String
    var onTap: () -> Void

    var body: some View {
        HStack(spacing: 5) {
            Text(question).foregroundStyle(forge.textSecondary)
            Button(action, action: onTap).foregroundStyle(forge.accent)
        }
        .font(.forgeBodyMedium(14))
    }
}
