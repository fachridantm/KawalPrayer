import Foundation
import AVFoundation
import Observation

@Observable
final class AudioService: NSObject {

    static let shared = AudioService()

    var isPlaying: Bool = false
    var volume: Float = 1.0 {
        didSet {
            player?.volume = volume
        }
    }
    var onAdzanFinished: (() -> Void)?

    private var player: AVAudioPlayer?

    private override init() { super.init() }

    // MARK: - Public

    func playAdzan(soundName: String = "adzan_makkah", volumeLevel: Double = 1.0) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("[AudioService] File not found: \(soundName).mp3")
            return
        }
        do {
            player?.stop()
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            self.volume = Float(max(0.0, min(1.0, volumeLevel)))
            player?.volume = self.volume
            player?.play()
            isPlaying = true
            print("[AudioService] Playing \(soundName) with volume \(self.volume)")
        } catch {
            print("[AudioService] Playback error: \(error)")
        }
    }

    func stopAdzan() {
        let wasPlaying = isPlaying
        player?.stop()
        player = nil
        isPlaying = false
        // Manual stop also triggers onAdzanFinished so Doa popup and Iqamah flow continue smoothly
        if wasPlaying {
            onAdzanFinished?()
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = false
            self?.onAdzanFinished?()
        }
    }
}
