//
//  TrackListDownloader.swift
//  iTunes Previews
//
//  Created by Polina Dulko on 1/27/19.
//  Copyright © 2019 Polina Dulko. All rights reserved.
//

import Foundation

protocol TrackListDownloaderDelegate {
    func downloadDidFinished(sender: TrackListDownloader)
}

class TrackListDownloader {
    var keyword = ""
    var tracks = [Track]()
    var delegate: TrackListDownloaderDelegate?
    
    func downloadListOfTracks() {
        tracks.removeAll()
        guard let url = URL(string: "https://itunes.apple.com/search?term=" + keyword + "&media=music") else { return }
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            if let data = data {
                if let listOfTracks = self.parseJson(data: data) {
                    self.tracks = listOfTracks
                    if let delegate = self.delegate {
                        delegate.downloadDidFinished(sender: self)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    func parseJson(data: Data) -> [Track]? {
        var tracks = [Track]()
        do {
            let reply = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
            let objects = reply!["results"] as! [AnyObject]
            for object in objects {
                let artistName = object["artistName"] as! String
                let trackName = object["trackName"] as! String
                let trackExplicitness = object["trackExplicitness"] as! String
                var isTrackExplicit = true
                if trackExplicitness == "notExplicit" {
                    isTrackExplicit = false
                }
                let artworkURLStr = object["artworkUrl100"] as? String
                let viewURLStr = object["trackViewUrl"] as? String
                let previewURLStr = object["previewUrl"] as? String
                let track = Track(artistName: artistName, trackName: trackName, isExplicit: isTrackExplicit, artworkURL: createURLFromString(str: artworkURLStr), viewURL: createURLFromString(str: viewURLStr), previewURL: createURLFromString(str: previewURLStr))
                tracks.append(track)
            }
        } catch {
            print(error)
            return nil
        }
        return tracks
    }
    
    func createURLFromString(str: String?) -> URL? {
        var url: URL? = nil
        if let urlStr = str {
            url = URL(string: urlStr)
            return url
        }
        return nil
    }
}
