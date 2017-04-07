//
//  HomeViewController.swift
//  Boilerplate
//
//  Created by JohnP on 4/7/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    fileprivate let dataSource = ExploreWordsDataSource()
    fileprivate let viewModel: HomePageViewModelType = HomePageViewModel()
    
    internal static func instantiate() -> HomeViewController {
        return JPStoryboard.Home.instantiate(HomeViewController.self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
