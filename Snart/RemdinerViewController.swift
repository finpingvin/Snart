//
//  RemdinerViewController.swift
//  Snart
//
//  Created by Daniel Björkander on 2019-05-02.
//  Copyright © 2019 Daniel Björkander. All rights reserved.
//

import UIKit

class ReminderViewController: UIViewController {
    @IBOutlet weak var reminderImage: UIImageView!
    
    override func viewDidLoad() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        if let imageURL = delegate.reminderImage {
            do {
                let imageData = try Data(contentsOf: imageURL)
                reminderImage.image = UIImage(data: imageData)
            }
            catch let error {
                print("Error: Unable to load image: \(error.localizedDescription)")
            }
        }
    }
}
