import SwiftUI

struct PushupCaptureView: View {
    @EnvironmentObject var viewModel: PushupViewModel
    @StateObject private var cameraManager = CameraPreviewManager()
    @State private var isEndingSession = false

    var body: some View {
        ZStack {
            CameraPreviewView(session: cameraManager.session)
                .ignoresSafeArea()
            
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("Today's Pushups")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 24) {
                        Button {
                            viewModel.handleDecrement()
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 44, weight: .semibold))
                                .foregroundStyle(.white)
                                .background(Color.red.opacity(0.8))
                                .clipShape(Circle())
                        }
                        
                        Text("\(viewModel.todayCount)")
                            .font(.system(size: 72, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                if viewModel.isSessionActive {
                    VStack(spacing: 8) {
                        Text("Live session")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("\(viewModel.sessionCount)")
                            .font(.system(size: 56, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                } else {
                    VStack(spacing: 16) {
                        Text("Tap the start button to begin")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 40)
                    }
                }
                
                Button {
                    if viewModel.isSessionActive {
                        isEndingSession = true
                        viewModel.endSession()
                        cameraManager.stopSession()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isEndingSession = false
                        }
                    } else {
                        viewModel.startSession()
                        cameraManager.startSession()
                    }
                } label: {
                    Text(viewModel.isSessionActive ? "End Session" : "Start Session")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isSessionActive ? Color.red.opacity(0.8) : Color.green.opacity(0.8))
                        .foregroundStyle(.white)
                        .cornerRadius(16)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
            .padding()
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if viewModel.isSessionActive && !isEndingSession {
                        viewModel.handleTouch()
                    }
                }
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    if viewModel.isSessionActive && !isEndingSession {
                        viewModel.handleTouch()
                    }
                }
        )
        .onAppear {
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }
}

#Preview {
    PushupCaptureView()
        .environmentObject(PushupViewModel())
}
