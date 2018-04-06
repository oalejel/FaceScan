//
//  ViewController.swift
//  FaceScan
//
//  Created by Omar Al-Ejel on 4/6/18.
//  Copyright © 2018 Omar Al-Ejel. All rights reserved.
//

import UIKit
import AVFoundation

/*
 Notes (remove on completion)
 – to add to configurations: convert to swift 4 for nicer enum philosophy!
 – review comments made
 – a constraint of 999 was need for the sake of calming an error involving localization and constrained button labels. when you add loc. you consider these things
 
 
 
 do this:
 convert unwrapped to normal optionals
 */

class ViewController: UIViewController {

    @IBAction func scanPressed(_ sender: Any) {
        // must request permission to use camera
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { response in
            if response {
                //access granted
                self.presentCamera()
            } else {
                print("access to camera denied by user")
            }
        }
    }
    
    //when scan pressed, show our scanning scene!
    func presentCamera() {
        performSegue(withIdentifier: "showScanner", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

