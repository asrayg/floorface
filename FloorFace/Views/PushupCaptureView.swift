//
//  PushupCaptureView.swift
//  FloorFace
//
//  Full-screen capture surface for FloorFace.
//

import SwiftUI
import AVFoundation

struct PushupCaptureView: View {
    @EnvironmentObject var viewModel: PushupViewModel
    @StateObject private var cameraManager = CameraPreviewManager()
    @State private var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined

    var body: some View {
        ZStack {
            if cameraPermissionStatus == .authorized {
                CameraPreviewView(session: cameraManager.session)
                    .ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: [.black, .purple.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            // Semi-transparent overlay to keep text readable
            Color.black.opacity(0.3)
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

                if viewModel.isSessionActive {
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
                        cameraManager.stopSession()
                    } label: {
                        Text("End Session")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundStyle(.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 16) {
                        Text("Tap the start button to begin")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 40)
                    }
                }
            }
            .padding()
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if viewModel.isSessionActive {
                        viewModel.handleTouch()
                    }
                }
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    if viewModel.isSessionActive {
                        viewModel.handleTouch()
                    }
                }
        )
        .onAppear {
            checkCameraPermission()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        .overlay(alignment: .topTrailing) {
            if !viewModel.isSessionActive {
                Button {
                    viewModel.startSession()
                    if cameraPermissionStatus == .authorized {
                        cameraManager.startSession()
                    }
                } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color.green.opacity(0.8))
                        .clipShape(Circle())
                }
                .padding(.top, 60)
                .padding(.trailing, 20)
            }
        }
        .overlay(alignment: .bottom) {
            if cameraPermissionStatus != .authorized {
                VStack(spacing: 12) {
                    Text("Enable camera to see live preview")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    Button {
                        requestCameraAccess()
                    } label: {
                        Text("Enable Camera")
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding()
            }
        }
    }
    
    private func checkCameraPermission() {
        cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    private func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                cameraPermissionStatus = granted ? .authorized : .denied
                if granted {
                    cameraManager.startSession()
                }
            }
        }
    }
}

#Preview {
    PushupCaptureView()
        .environmentObject(PushupViewModel())
}
