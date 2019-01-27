//
//  AudioPlayer.swift
//  iTunes Previews
//
//  Created by Polina Dulko on 1/27/19.
//  Copyright © 2019 Polina Dulko. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class AudioPlayer {
    let session = AVAudioSession.sharedInstance()
    var player: AVAudioPlayer?
    var delegate: UIViewController?
    
    init() {
        try? session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
    }
    
    func startPlaying(audioURL: URL, delegate: UIViewController) {
        guard let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let audioFilePath = directoryPath.appendingPathComponent("preview.m4a")
        let downloadTask = URLSession.shared.downloadTask(with: audioURL) { (URLData, response, error) in
            if let error = error {
                print(error)
                return
            }
            if let data = URLData {
                do {
                    let isFileFound = FileManager.default.fileExists(atPath: audioFilePath.path)
                    if isFileFound {
                        try FileManager.default.removeItem(at: audioFilePath)
                    }
                    try FileManager.default.copyItem(at: data, to: audioFilePath)
                    let audioPlayer = try AVAudioPlayer(contentsOf: audioFilePath)
                    audioPlayer.delegate = delegate as? AVAudioPlayerDelegate
                    self.player = audioPlayer
                    self.continuePlaying()
                } catch {
                    print(error)
                    return
                }
            }
        }
        downloadTask.resume()
    }
    
    func continuePlaying() {
        if let audioPlayer = player {
            try? session.setActive(true)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }
    
    func pause() {
        if let audioPlayer = player {
            try? session.setActive(false)
            audioPlayer.pause()
        }
    }
    
    func stop() {
        if let audioPlayer = player {
            try? session.setActive(false)
            audioPlayer.stop()
        }
    }
}
