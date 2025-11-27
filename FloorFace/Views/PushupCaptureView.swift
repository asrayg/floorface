//
//  PushupCaptureView.swift
//  NoseTap
//
//  Full-screen capture surface for nose taps.
//

import SwiftUI

struct PushupCaptureView: View {
    @EnvironmentObject var viewModel: PushupViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, .purple.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("Today's Pushups")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 24) {
                        
                        Text("\(viewModel.todayCount)")
                            .font(.system(size: 72, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                VStack(spacing: 8) {
                    Text("Live session")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.sessionCount)")
                        .font(.system(size: 56, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Button {
                    viewModel.endSession()
                } label: {
                    Text("End Session")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .foregroundStyle(.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    viewModel.handleTouch()
                }
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    viewModel.handleTouch()
                }
        )
    }

}

#Preview {
    PushupCaptureView()
        .environmentObject(PushupViewModel())
}
