//
//  ViewController.swift
//  iTunes Previews
//
//  Created by Polina Dulko on 1/27/19.
//  Copyright © 2019 Polina Dulko. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet var tracksTableView: UITableView!
    let tracksTableViewCellHeight: CGFloat = 110
    @IBOutlet weak var searchTextField: UITextField!
    let trackListDownloader = TrackListDownloader()
    var tracks = [Track]()
    let audioPlayer = AudioPlayer()
    var currentPlayerButton: PlayerButton?
    let networkReachabilityManager = NetworkReachabilityManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tracksTableView.dataSource = self
        tracksTableView.delegate = self
        tracksTableView.showsVerticalScrollIndicator = false
        tracksTableView.tableFooterView = UIView(frame: .zero)
        trackListDownloader.delegate = self
        let tapOnViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(finishSearchTextFieldEditing))
        self.view.addGestureRecognizer(tapOnViewGestureRecognizer)
    }
    
    @objc func finishSearchTextFieldEditing() {
        searchTextField.endEditing(true)
    }
    
    @IBAction func search(_ sender: UITextField) {
        //Checking of Internet connection
        if networkReachabilityManager.isNetworkReachable() {
            if let keywordForSearch = sender.text {
                trackListDownloader.keyword = keywordForSearch
                trackListDownloader.downloadListOfTracks()
            }
        }
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
            if networkReachabilityManager.isNetworkReachable() {
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let goToiTunesAction = UITableViewRowAction(style: .normal, title: "") { (action, indexPath) in
            let cell = tableView.cellForRow(at: indexPath) as! TrackTableViewCell
            guard let track = cell.track else {
                return
            }
            if let viewURL = track.viewURL {
                let canOpen = UIApplication.shared.canOpenURL(viewURL)
                if canOpen {
                    UIApplication.shared.open(viewURL, options: [:], completionHandler: nil)
                } else {
                    let alert = UIAlertController(title: "Link to iTunes", message: "Can't open track in iTunes", preferredStyle: .alert)
                    let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAlertAction)
                    self.present(alert, animated: true)
                }
            }
        }
        goToiTunesAction.backgroundColor = UIColor.white
        return [goToiTunesAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
