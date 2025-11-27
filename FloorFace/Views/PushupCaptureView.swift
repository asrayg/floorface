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
            if viewModel.isCameraAuthorized, let session = viewModel.previewSession {
                CameraPreviewView(session: session)
                    .ignoresSafeArea()
            } else {
                Color.black
                    .ignoresSafeArea()
            }

            LinearGradient(
                colors: [.black.opacity(0.8), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                VStack {
                    Text("Today")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.todayCount)")
                        .font(.system(size: 72, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                }

                VStack {
                    Text("Live session")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.sessionCount)")
                        .font(.system(size: 56, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }

                if viewModel.isRecordingClip {
                    Label("Recording mini video…", systemImage: "video.fill")
                        .font(.subheadline)
                        .foregroundStyle(.yellow)
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

                cameraPermissionOverlay
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
        .alert("Recording error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.errorMessage = nil
                }
            }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            viewModel.evaluateCameraPermission()
            viewModel.startCameraPreview()
        }
        .onDisappear {
            viewModel.stopCameraPreview()
        }
    }

    @ViewBuilder
    private var cameraPermissionOverlay: some View {
        if viewModel.cameraPermissionStatus != .authorized {
            VStack(spacing: 12) {
                Text("Camera access is disabled")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Text("Enable the front camera to see live video and save GIFs from each session.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button {
                    viewModel.requestCameraAccess()
                } label: {
                    Text("Enable Camera Access")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .padding()
        } else if viewModel.previewSession == nil {
            Text("Camera unavailable on this device.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

#Preview {
    PushupCaptureView()
        .environmentObject(PushupViewModel())
}

