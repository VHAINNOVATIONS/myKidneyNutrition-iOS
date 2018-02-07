//
//  WelcomePage1ViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/2/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import SwiftyJSON
import UIComponents

/**
 * Welcome screen #1
 *
 * - author: TCCODER
 * - version: 1.0
 */
class WelcomePage1ViewController: UIViewController {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstLineView: UIView!
    @IBOutlet weak var lastLineView: UIView!
    @IBOutlet weak var message1Label: UILabel!
    @IBOutlet weak var message2Label: UILabel!
    @IBOutlet weak var message3Label: UILabel!
    @IBOutlet weak var topHeight: NSLayoutConstraint!
    @IBOutlet weak var topMargin: NSLayoutConstraint!

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.setLineSpacing(lineSpacing: 1.5)
        if !OPTION_FIX_DESIGN_ISSUES {
            firstLineView.backgroundColor = Colors.blue
            lastLineView.backgroundColor = Colors.blue
        }
        loadData()
    }

    /// Load data
    private func loadData() {
        if let json = JSON.resource(named: "welcome1") {
            message1Label.text = json["message1"].stringValue
            message2Label.text = json["message2"].stringValue
            message3Label.text = json["message3"].stringValue
        }
        if isIPhone5() {
            topHeight.constant = 120
            topMargin.constant = 20
            message1Label.font = UIFont(name: message1Label.font.familyName, size: 10)
            message2Label.font = UIFont(name: message2Label.font.familyName, size: 10)
            message3Label.font = UIFont(name: message3Label.font.familyName, size: 10)
        }
        message1Label.setLineSpacing(lineSpacing: 3)
        message2Label.setLineSpacing(lineSpacing: 3)
        message3Label.setLineSpacing(lineSpacing: 3)
    }
}
