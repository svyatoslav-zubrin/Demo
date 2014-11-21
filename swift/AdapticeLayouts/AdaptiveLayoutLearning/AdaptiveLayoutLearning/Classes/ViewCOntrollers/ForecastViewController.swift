//
//  ForecastViewController.swift
//  AdaptiveLayoutLearning
//
//  Created by Slava Zubrin on 11/18/14.
//  Copyright (c) 2014 Slava Zubrin. All rights reserved.
//

import UIKit

class ForecastViewController: UIViewController {

    // public
//    var cityName: String? {
//        didSet
//        {
//            self.cityNameLabel?.text =
//        }
//    }
    
    // XIB
    @IBOutlet var cityNameLabel: UILabel?
    
    
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
