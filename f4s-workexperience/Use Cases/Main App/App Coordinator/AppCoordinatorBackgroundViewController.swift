//
//  AppCoordinatorBackgroundViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 17/02/2019.
//  Copyright © 2019 Workfinder Ltd. All rights reserved.
//

import  UIKit
import WorkfinderCommon
import WorkfinderUI

class AppCoordinatorBackgroundViewController : UIViewController {
    
    var backgroundImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "launch_screen_image"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var logo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 140).isActive = true
        return imageView
    }()
    
//    var label: UILabel = {
//        let label = UILabel()
//        label.text = "Find flexible work opportunities with fast growing companies"
//        label.numberOfLines = 0
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.widthAnchor.constraint(equalToConstant: 200).isActive = true
//        label.font = UIFont.systemFont(ofSize: 30, weight: .thin)
//        label.textColor = UIColor.white
//        label.textAlignment = .center
//        return label
//    }()
    
    override func viewDidLoad() {
        configureViews()
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.black
        view.addSubview(backgroundImage)
        view.addSubview(logo)
        //view.addSubview(label)
        backgroundImage.fillSuperview()
        logo.topAnchor.constraint(equalTo: backgroundImage.safeAreaLayoutGuide.topAnchor, constant: 80).isActive = true
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        label.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 25).isActive = true
//        label.centerXAnchor.constraint(equalTo: logo.centerXAnchor).isActive = true
    }
    
}
