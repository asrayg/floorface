import AVFoundation
import Combine

final class CameraPreviewManager: ObservableObject {
    @Published var session = AVCaptureSession()
    private var isConfigured = false

    init() {
        configureSession()
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .front
              ),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input)
        else {
            session.commitConfiguration()
            return
        }

        session.addInput(input)
        session.commitConfiguration()
        isConfigured = true
    }

    func startSession() {
        guard isConfigured, !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }

    func stopSession() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.stopRunning()
        }
    }
}
