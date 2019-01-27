//
//  TrackTableViewCell.swift
//  iTunes Previews
//
//  Created by Polina Dulko on 1/27/19.
//  Copyright © 2019 Polina Dulko. All rights reserved.
//

import UIKit

class TrackTableViewCell: UITableViewCell {

    @IBOutlet var artworkImageView: UIImageView!
    @IBOutlet var explicitImageView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var playButton: PlayerButton!
    var track: Track? {
        didSet {
            if let track = track {
                artistNameLabel.text = track.artistName
                trackNameLabel.text = track.trackName
                if track.isExplicit {
                    explicitImageView.isHidden = false
                } else {
                    explicitImageView.isHidden = true
                }
                if let artworkURL = track.artworkURL {
                    downloadAndSetImage(imageURL: artworkURL)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        explicitImageView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func playButtonTapped(_ sender: PlayerButton) {
    }
    
    func downloadAndSetImage(imageURL: URL) {
        let dataTask = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            if let data = data {
                DispatchQueue.main.async {
                    self.artworkImageView.image = UIImage(data: data)
                }
            }
        }
        dataTask.resume()
    }
    
}
