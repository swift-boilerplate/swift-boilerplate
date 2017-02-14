//
//  Coordinator.swift
//  Facestar
//
//  Created by JohnP on 2/11/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Foundation
import UIKit

class Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}
