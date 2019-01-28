//
//  NetworkReachabilityManager.swift
//  iTunes Previews
//
//  Created by Polina Dulko on 1/28/19.
//  Copyright © 2019 Polina Dulko. All rights reserved.
//

import Foundation
import SystemConfiguration

class NetworkReachabilityManager {
    func isNetworkReachable() -> Bool {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, "localhost") else { return false }
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability, &flags)
        let isReachable = flags.contains(.reachable)
        let isConnectionRequired = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        return (isReachable && (!isConnectionRequired || canConnectWithoutUserInteraction)) || flags.contains(.isWWAN)
    }
}
