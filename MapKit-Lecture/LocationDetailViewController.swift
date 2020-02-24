//
//  LocationDetailViewController.swift
//  MapKit-Lecture
//
//  Created by casandra grullon on 2/24/20.
//  Copyright © 2020 casandra grullon. All rights reserved.
//

import UIKit

class LocationDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    private var location: Location
    
    init?(coder: NSCoder, location: Location) {
        self.location = location
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(named: location.imageName)

    }
    


}
