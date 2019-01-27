//
//  ViewController.swift
//  iTunes Previews
//
//  Created by Polina Dulko on 1/27/19.
//  Copyright © 2019 Polina Dulko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var tracksTableView: UITableView!
    let tracksTableViewCellHeight: CGFloat = 110
    let downloader = TrackListDownloader()
    var tracks = [Track]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tracksTableView.dataSource = self
        tracksTableView.delegate = self
        downloader.delegate = self
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
}
