//
//  GIFService.swift
//  NoseTap
//
//  Converts short video clips into animated GIFs saved on disk.
//

import Foundation
import AVFoundation
import ImageIO
import UniformTypeIdentifiers

final class GIFService {
    static let shared = GIFService()
    private let queue = DispatchQueue(label: "com.nosetap.gifservice")

    func createGIFFromVideo(videoURL: URL, destinationURL: URL, frameCount: Int = 16, completion: @escaping (Result<URL, Error>) -> Void) {
        queue.async {
            let asset = AVAsset(url: videoURL)
            let durationSeconds = CMTimeGetSeconds(asset.duration)

            guard durationSeconds > 0 else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "GIFService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Video duration is zero."])))
                }
                return
            }

            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let step = max(durationSeconds / Double(frameCount), 0.05)
            var times: [CMTime] = []
            var current: Double = 0

            while current < durationSeconds {
                times.append(CMTime(seconds: current, preferredTimescale: 600))
                current += step
            }
            if times.isEmpty {
                times.append(CMTime(seconds: 0, preferredTimescale: 600))
            }

            guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, UTType.gif.identifier as CFString, times.count, nil) else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "GIFService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Unable to create GIF destination."])))
                }
                return
            }

            let frameDelay = step
            let frameProps = [
                kCGImagePropertyGIFDictionary as String: [
                    kCGImagePropertyGIFDelayTime as String: frameDelay
                ]
            ]
            let gifProps = [
                kCGImagePropertyGIFDictionary as String: [
                    kCGImagePropertyGIFLoopCount as String: 0
                ]
            ]
            CGImageDestinationSetProperties(destination, gifProps as CFDictionary)

            for time in times {
                do {
                    let imageRef = try generator.copyCGImage(at: time, actualTime: nil)
                    CGImageDestinationAddImage(destination, imageRef, frameProps as CFDictionary)
                } catch {
                    continue
                }
            }

            if CGImageDestinationFinalize(destination) {
                DispatchQueue.main.async {
                    completion(.success(destinationURL))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "GIFService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to finalize GIF."])))
                }
            }
        }
    }
}

