//
//  ViewController.swift
//  iTunes Previews
//
//  Created by Polina Dulko on 1/27/19.
//  Copyright © 2019 Polina Dulko. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tracksTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tracksTableView.dataSource = self
        tracksTableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tracksTableView.dequeueReusableCell(withIdentifier: "TrackCell") as! TrackTableViewCell
        return cell
    }

}

