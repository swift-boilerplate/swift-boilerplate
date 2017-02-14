//
//  Storyboard.swift
//  Facestar
//
//  Created by JohnP on 2/11/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Foundation
import UIKit

public enum JPStoryboard: String {
    case Discovery
    case Activity
    case Setting
    case Dashboard
    case Profile
    case Home
    
    public func instantiate<VC: UIViewController>(_ viewController: VC.Type,
                            inBundle bundle: Bundle = .framework) -> VC {
        guard
            let vc = UIStoryboard(name: self.rawValue, bundle: nil)
                .instantiateViewController(withIdentifier: VC.storyboardIdentifier) as? VC
            else { fatalError("Couldn't instantiate \(VC.storyboardIdentifier) from \(self.rawValue)") }
        
        return vc
    }
}
