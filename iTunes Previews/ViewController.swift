//
//  ViewController.swift
//  iTunes Previews
//
//  Created by Polina Dulko on 1/27/19.
//  Copyright © 2019 Polina Dulko. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class ViewController: UIViewController {
    @IBOutlet var tracksTableView: UITableView!
    let tracksTableViewCellHeight: CGFloat = 110
    @IBOutlet weak var searchTextField: UITextField!
    let trackListDownloader = TrackListDownloader()
    var tracks = [Track]()
    let audioPlayer = AudioPlayer()
    var currentPlayerButton: PlayerButton?
    @IBOutlet weak var clearSearchButton: UIButton!
    let networkReachabilityManager = NetworkReachabilityManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tracksTableView.dataSource = self
        tracksTableView.delegate = self
        tracksTableView.showsVerticalScrollIndicator = false
        tracksTableView.tableFooterView = UIView(frame: .zero)
        trackListDownloader.delegate = self
        searchTextField.delegate = self
        clearSearchButton.isHidden = true
        let tapOnViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(finishSearchTextFieldEditing))
        self.view.addGestureRecognizer(tapOnViewGestureRecognizer)
    }
    
    @objc func finishSearchTextFieldEditing() {
        searchTextField.endEditing(true)
    }
    
    @IBAction func search(_ sender: UITextField) {
        guard let networkReachabilityManager = networkReachabilityManager else { return }
        if networkReachabilityManager.isReachable {
            if let keywordForSearch = sender.text {
                stopPlayingAudio()
                trackListDownloader.keyword = keywordForSearch
                trackListDownloader.downloadListOfTracks()
            }
        }
    }
    
    @IBAction func clearSearchButtonTapped(_ sender: UIButton) {
        searchTextField.text = ""
    }
    
    @IBAction func playerButtonTapped(_ sender: PlayerButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tracksTableView)
        guard let indexPath = tracksTableView.indexPathForRow(at: buttonPosition) else { return }
        guard let audioURL = tracks[indexPath.row].previewURL else { return }
        if currentPlayerButton != sender {
            //Checking of Internet connection
            if let player = audioPlayer.player {
                if player.isPlaying {
                    audioPlayer.stop()
                }
            }
            if currentPlayerButton != nil {
                currentPlayerButton!.isPauseButton = false
            }
            guard let networkReachabilityManager = networkReachabilityManager else { return }
            if networkReachabilityManager.isReachable {
                sender.isPauseButton = true
                currentPlayerButton = sender
                audioPlayer.startPlaying(audioURL: audioURL, delegate: self)
            }
        } else {
            if let player = audioPlayer.player {
                if player.isPlaying {
                    audioPlayer.pause()
                    sender.isPauseButton = false
                } else {
                    audioPlayer.continuePlaying()
                    sender.isPauseButton = true
                }
            }
        }
    }
    
    func stopPlayingForNonvisibleCells() {
        guard let currentPlayerButton = currentPlayerButton else { return }
        let playerButtonPosition = currentPlayerButton.convert(CGPoint.zero, to: tracksTableView)
        guard let playingIndexPath = tracksTableView.indexPathForRow(at: playerButtonPosition) else { return }
        guard let indexPathsForVisibleRows = tracksTableView.indexPathsForVisibleRows else { return }
        var isVisible = false
        for indexPath in indexPathsForVisibleRows {
            if playingIndexPath == indexPath {
                isVisible = true
            }
        }
        if !isVisible {
            stopPlayingAudio()
        }
    }
    
    func stopPlayingAudio() {
        guard let currentPlayerButton = currentPlayerButton else { return }
        if let player = audioPlayer.player {
            if player.isPlaying {
                audioPlayer.stop()
            }
        }
        currentPlayerButton.isPauseButton = false
    }
}

//TrackListDownloader protocol
extension ViewController: TrackListDownloaderDelegate {
    func downloadDidFinished(sender: TrackListDownloader) {
        self.tracks = sender.tracks
        DispatchQueue.main.async {
            self.tracksTableView.reloadData()
        }
    }
}

//AVAudioPlayer protocol
extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let currentPlayerButton = currentPlayerButton {
            currentPlayerButton.isPauseButton = !currentPlayerButton.isPauseButton
        }
    }
}

//TableView protocols
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tracksTableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tracksTableView.dequeueReusableCell(withIdentifier: "TrackCell") as! TrackTableViewCell
        cell.track = tracks[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let configuration = UISwipeActionsConfiguration(actions: [])
        return configuration
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        stopPlayingForNonvisibleCells()
    }
}

//TextField protocol
extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        clearSearchButton.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        clearSearchButton.isHidden = true
    }
}
