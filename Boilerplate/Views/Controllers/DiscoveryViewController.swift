//
//  DiscoveryViewController.swift
//  Boilerplate
//
//  Created by JohnP on 2/11/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import UIKit

internal final class DiscoveryViewController: UIViewController {
    
    internal static func instantiate() -> DiscoveryViewController {
        return JPStoryboard.Discovery.instantiate(DiscoveryViewController.self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
