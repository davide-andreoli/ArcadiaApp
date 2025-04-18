//
//  CurrentBufferAudioPlayer.swift
//  Arcadia
//
//  Created by Davide Andreoli on 17/05/24.
//
import AVFoundation

class CurrentBufferAudioPlayer {
    private var audioEngine: AVAudioEngine
    private var playerNode: AVAudioPlayerNode
    private var audioFormat: AVAudioFormat

    private let bufferUpdateQueue = DispatchQueue(label: "com.Arcadia.bufferUpdateQueue", qos: .userInteractive)

    init() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()

        let sampleRate: Double = 44100
        let channels: AVAudioChannelCount = 2 // Two channels for stereo

        // Use Float32 format with non-interleaved data
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: channels) else {
            fatalError("Failed to create audio format")
        }
        audioFormat = format

        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioFormat)
    }

    func start() {
        do {
            try audioEngine.start()
            playerNode.play()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }

    func updateBuffer(with audioData: [Float32]) {
        bufferUpdateQueue.async { [weak self] in
            guard let self = self else { return }
            
            let frameCount = AVAudioFrameCount(audioData.count / Int(self.audioFormat.channelCount))
            guard let buffer = AVAudioPCMBuffer(pcmFormat: self.audioFormat, frameCapacity: frameCount) else {
                print("Failed to create PCM buffer with frame capacity \(frameCount)")
                return
            }
            buffer.frameLength = frameCount

            // Get pointers to each channel's data buffer
            guard let channelData = buffer.floatChannelData else {
                print("Failed to get float channel data")
                return
            }

            // Directly copy the audio data into the channel buffers
            for channel in 0..<Int(self.audioFormat.channelCount) {
                let stride = Int(self.audioFormat.channelCount)
                for frame in 0..<Int(frameCount) {
                    channelData[channel][frame] = audioData[frame * stride + channel]
                }
            }
            
            self.playerNode.scheduleBuffer(buffer, completionHandler: nil) //Works but audio is late
            
            //self.playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil) // Works but audio is choppy
        }
    }

}
