//
//  DashboardViewController.swift
//  Facestar
//
//  Created by JohnP on 2/11/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    
    internal static func instantiate() -> DiscoveryViewController {
        return JPStoryboard.Discovery.instantiate(DiscoveryViewController.self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

}
