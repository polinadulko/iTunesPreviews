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
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var trackNameLabel: UILabel!
    var originalCenter = CGPoint()
    var minOffsetOfSwipe: CGFloat = 20
    var shouldGoToItunes = false
    
    var track: Track? {
        didSet {
            if let track = track {
                artistNameLabel.text = track.artistName
                trackNameLabel.text = track.trackName
                if let artworkURL = track.artworkURL {
                    downloadAndSetImage(imageURL: artworkURL)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(cellSwipeHandler(sender:)))
        panGestureRecognizer.delegate = self
        self.addGestureRecognizer(panGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
    
    @objc func cellSwipeHandler(sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            originalCenter = center
        }
        if sender.state == .changed {
            let translation = sender.translation(in: self)
            let newCenter = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
            self.center = newCenter
            if translation.x > minOffsetOfSwipe {
                shouldGoToItunes = true
            }
        }
        if sender.state == .ended {
            if shouldGoToItunes {
                openTrackInItunes()
                shouldGoToItunes = false
            }
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            UIView.animate(withDuration: 0.2) {
                self.frame = originalFrame
            }
        }
    }
    
    func openTrackInItunes() {
        guard let track = self.track else { return }
        if let viewURL = track.viewURL {
            let canOpen = UIApplication.shared.canOpenURL(viewURL)
            if canOpen {
                UIApplication.shared.open(viewURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: self)
            if abs(translation.x) > abs(translation.y) {
                return true
            }
        }
        return false
    }
}
