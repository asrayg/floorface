//
//  VideoRecorder.swift
//  NoseTap
//
//  Records short clips and exposes a preview session for live video.
//

import AVFoundation
import Foundation

final class VideoRecorder: NSObject, AVCaptureFileOutputRecordingDelegate {
    enum RecorderError: LocalizedError {
        case cameraUnavailable
        case sessionNotReady

        var errorDescription: String? {
            switch self {
            case .cameraUnavailable:
                return "Camera not available on this device."
            case .sessionNotReady:
                return "Camera session was not ready."
            }
        }
    }

    static let shared = VideoRecorder()

    let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private let captureQueue = DispatchQueue(label: "com.nosetap.videorecorder")
    private var completion: ((Result<URL, Error>) -> Void)?
    private var isSessionConfigured = false

    override init() {
        super.init()
        configureSession()
    }

    var previewSession: AVCaptureSession? {
        isSessionConfigured ? session : nil
    }

    private func configureSession() {
#if targetEnvironment(simulator)
        isSessionConfigured = false
        return
#else
        session.beginConfiguration()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)

        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        }

        session.commitConfiguration()
        isSessionConfigured = true
#endif
    }

    func startPreview() {
        guard isSessionConfigured else { return }
        captureQueue.async { [weak self] in
            guard let self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func stopPreview() {
        guard isSessionConfigured, !movieOutput.isRecording else { return }
        captureQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    func recordClip(duration: TimeInterval = 3, completion: @escaping (Result<URL, Error>) -> Void) {
        guard isSessionConfigured else {
            DispatchQueue.main.async {
                completion(.failure(RecorderError.cameraUnavailable))
            }
            return
        }
        self.completion = completion
        captureQueue.async { [weak self] in
            guard let self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
            }

            guard self.movieOutput.connection(with: .video)?.isEnabled == true else {
                DispatchQueue.main.async {
                    completion(.failure(RecorderError.sessionNotReady))
                }
                return
            }

            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")

            self.movieOutput.startRecording(to: tempURL, recordingDelegate: self)

            self.captureQueue.asyncAfter(deadline: .now() + duration) { [weak self] in
                guard let self else { return }
                if self.movieOutput.isRecording {
                    self.movieOutput.stopRecording()
                }
            }
        }
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error {
            completion?(.failure(error))
        } else {
            completion?(.success(outputFileURL))
        }
        completion = nil
    }
}
//
//  VideoRecorder.swift
//  NoseTap
//
//  Records a short video clip using the front camera for GIF conversion.
//


