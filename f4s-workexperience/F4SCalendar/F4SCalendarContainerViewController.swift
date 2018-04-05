//
//  F4SCalendarContainerViewController.swift
//  HoursPicker2
//
//  Created by Keith Dev on 03/04/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SCalendarContainerViewController: UIViewController {
    @IBOutlet weak var pageHeaderView: F4SPageHeaderView!
    
    var splashColor = UIColor(red: 72/255, green: 38/255, blue: 127/255, alpha: 1.0)
    var delegate: F4SCalendarCollectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationController(titleColor: UIColor.white, backgroundColor: splashColor, tintColor: UIColor.white, useLightStatusBar: true)
    }
    
    func applyStyle() {
        pageHeaderView.splashColor = splashColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? F4SCalendarCollectionViewController else {
            return
        }
        vc.delegate = delegate
    }


}
