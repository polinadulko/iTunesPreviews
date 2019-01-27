//
//  Track.swift
//  iTunes Previews
//
//  Created by Polina Dulko on 1/27/19.
//  Copyright © 2019 Polina Dulko. All rights reserved.
//

import Foundation

class Track: NSObject {
    
    var artistName: String
    var trackName: String
    var isExplicit: Bool
    var artworkURL: URL?
    var viewURL: URL?
    var previewURL: URL?
    
    init(artistName: String, trackName: String, isExplicit: Bool, artworkURL: URL?, viewURL: URL?, previewURL: URL?) {
        self.artistName = artistName
        self.trackName = trackName
        self.isExplicit = isExplicit
        self.artworkURL = artworkURL
        self.viewURL = viewURL
        self.previewURL = previewURL
    }
    
}
