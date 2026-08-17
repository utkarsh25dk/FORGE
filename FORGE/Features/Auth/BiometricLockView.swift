import SwiftUI

struct BiometricLockView: View {
    @EnvironmentObject private var auth: AuthManager
    @Environment(\.forge) private var forge
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: Space.xl) {
            Spacer()
            Image(systemName: "faceid")
                .font(.system(size: 52))
                .foregroundStyle(forge.accent)
            VStack(spacing: 6) {
                Text("FORGE Locked").font(.forgeHeading(24)).foregroundStyle(forge.textPrimary)
                if let name = auth.currentAccount?.displayName {
                    Text("Welcome back, \(name)").font(.forgeBody(15)).foregroundStyle(forge.textSecondary)
                }
            }
            if let errorMessage {
                Text(errorMessage).font(.forgeCaption()).foregroundStyle(forge.danger).multilineTextAlignment(.center)
            }
            Spacer()
            Button {
                unlock()
            } label: {
                Text("Unlock with Face ID").frame(maxWidth: .infinity)
            }
            .forgeGlassPrimary()
            Button("Log Out") { auth.logOut() }
                .font(.forgeBodyMedium(14))
                .foregroundStyle(forge.textSecondary)
        }
        .padding(.horizontal, Space.xl)
        .padding(.bottom, Space.xl)
        .forgeScreenBackground()
        .onAppear { unlock() }
    }

    private func unlock() {
        auth.authenticateWithBiometrics { success, message in
            if !success { errorMessage = message }
        }
    }
}
