//
//  NotificationPromptView.swift
//  NoseTap
//
//  Modal shown on first launch to opt into reminders.
//

import SwiftUI

struct NotificationPromptView: View {
    let onEnable: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.badge")
                .font(.system(size: 48))
                .foregroundStyle(Color.accentColor)

            Text("Stay on track?")
                .font(.title2)
                .bold()

            Text("Enable reminders so NoseTap can nudge you for daily sessions and Sunday goal check-ins. You can always change this later in Settings.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button(action: onEnable) {
                Text("Enable Reminders")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }

            Button(action: onSkip) {
                Text("Maybe later")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding()
        .presentationDetents([.medium])
    }
}

#Preview {
    NotificationPromptView(onEnable: {}, onSkip: {})
}

