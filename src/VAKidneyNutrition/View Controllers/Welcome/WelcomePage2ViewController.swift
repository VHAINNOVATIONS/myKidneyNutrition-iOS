//
//  WelcomePage2ViewController.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/2/18.
//  Modified by TCCODER on 5/26/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import SwiftyJSON

/**
 * Welcome screen #2
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - font size changes
 */
class WelcomePage2ViewController: UIViewController {

    /// outlets
    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var message1Label: UILabel!
    @IBOutlet weak var message2Label: UILabel!
    @IBOutlet weak var image1Height: NSLayoutConstraint!
    @IBOutlet weak var image2Height: NSLayoutConstraint!
    @IBOutlet var topMargins: [NSLayoutConstraint]!

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        if let json = JSON.resource(named: "welcome2") {
            title1Label.text = json["title1"].stringValue.uppercased()
            title2Label.text = json["title2"].stringValue.uppercased()
            message1Label.text = json["message1"].stringValue
            message2Label.text = json["message2"].stringValue
        }
        if isIPhone5() {
            title1Label.font = UIFont(name: title1Label.font.familyName, size: 14)
            title2Label.font = UIFont(name: title2Label.font.familyName, size: 14)
            message1Label.font = UIFont(name: message1Label.font.familyName, size: 12)
            message2Label.font = UIFont(name: message2Label.font.familyName, size: 12)
            image1Height.constant = 50
            image2Height.constant = 50
            for c in topMargins {
                c.constant = 10
            }
        }
        message1Label.setLineSpacing(lineSpacing: 4)
        message2Label.setLineSpacing(lineSpacing: 4)
    }
}

