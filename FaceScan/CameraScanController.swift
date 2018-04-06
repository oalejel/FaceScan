//
//  CameraScanController.swift
//  FaceScan
//
//  Created by Omar Al-Ejel on 4/6/18.
//  Copyright © 2018 Omar Al-Ejel. All rights reserved.
//

import UIKit
import AVFoundation

class CameraScanController: UIViewController {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var snapTimer: Timer!
    var snapCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        // Do any additional setup after loading the view.
    }
    
    func saveImageData(images: [NSData]) {
        NSKeyedArchiver.archiveRootObject(images, toFile: "image_sequence")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //get our front camera
        let frontDevice = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
        // use built in screen capacitor to have extra light if needed
        if let f = frontDevice {
            if f.isLowLightBoostSupported {
                f.automaticallyEnablesLowLightBoostWhenAvailable = true
            }
        }

        do {
            let input = try AVCaptureDeviceInput(device: frontDevice)
            captureSession = AVCaptureSession()
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                let output = AVCapturePhotoOutput()
//                output.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])]) { (done, err) in
//                    print("done preparing settings")
//                    
//                }
                
                if self.captureSession.canAddOutput(output) {
                    self.captureSession.addOutput(output)
                    self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                    if let layer = self.previewLayer {
                        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
                        layer.connection?.videoOrientation = .portrait
                        layer.frame = self.view.bounds
                        self.view.layer.addSublayer(layer)
                        self.captureSession.startRunning()
                        
//                        if !self.captureSession.isRunning {
                            let fade = CABasicAnimation(keyPath: "opacity")
                            fade.fromValue = 0
                            fade.toValue = 1
                            fade.duration = 1
                            fade.isRemovedOnCompletion = false
                            layer.add(fade, forKey: "fadeIn")
//                        }
                        /// USE INSERT SUBLAYER WHEN YOU WANT TO SHOW TEXT ABOVE!
                    }
                }
            }
            
        } catch {
            print(error)
        }
        
        
        
        
        
        // at this stage, we show the user a timer and ask them to hold their head still
        beginSnapping()
    }
    
    //triggers our timer to repeat taking photos after showing a timer
    func beginSnapping() {
        // we want to take 10 photos with a frequency of 0.5 s
        snapTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in
            // change snapcount back to 10
            print("snapping number \(self.snapCount)")
            self.snapCount += 1
            if self.snapCount == 10 {
                timer.invalidate()
                //then tell user that we are done and leave
                self.dismiss(animated: true, completion: {
                    // do any completion cleanup if needed
                    // maybe have a thank you message
                })
            }
        })
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
