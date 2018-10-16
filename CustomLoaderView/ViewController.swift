//
//  ViewController.swift
//  CustomLoaderView
//
//  Created by Rahul Chopra on 28/08/18.
//  Copyright © 2018 Appsmall. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func showLoaderBtnPressed(_ sender: UIButton) {
        CustomLoaderView.shared().show(indicatorStyle: nil, headingText: nil, subHeadingText: nil)
    }
    
}
