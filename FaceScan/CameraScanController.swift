//
//  CameraScanController.swift
//  FaceScan
//
//  Created by Omar Al-Ejel on 4/6/18.
//  Copyright © 2018 Omar Al-Ejel. All rights reserved.
//

import UIKit
import AVFoundation


class CameraScanController: UIViewController, AVCapturePhotoCaptureDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var imgOuput: AVCapturePhotoOutput!
    var snapTimer: Timer!
    var snapCount = 0
    var noPendingImages = true
    var images: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        // Do any additional setup after loading the view.
    }
    
    func saveImageData() {
        for (index,image) in images.enumerated() {
            //create a secure NSKeyedArchiver to save images with indices
            // find way to activate this requirement on class
//            NSKeyedArchiver().requiresSecureCoding = true
            let fm = FileManager.default
            if let jpegData = UIImageJPEGRepresentation(image, 1) {
                let url = fm.urls(for: .documentDirectory, in: .userDomainMask).first
                let path = (url!.appendingPathComponent("faceImages_\(index)").path)
                NSKeyedArchiver.archiveRootObject(jpegData, toFile: path)
            }
        }
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
                imgOuput = AVCapturePhotoOutput()
                
                if self.captureSession.canAddOutput(imgOuput) {
                    self.captureSession.addOutput(imgOuput)
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
            
            //capture photo and be ready for a callback
            self.imgOuput.capturePhoto(with: AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg]), delegate: self)
            
            self.snapCount += 1
            print("snapping number \(self.snapCount)")
            if self.snapCount == 10 {
                //save our 10 images with
                self.saveImageData()
                
                timer.invalidate()
                //then tell user that we are done and leave
//                self.dismiss(animated: true, completion: {
//                    // do any completion cleanup if needed
//                    // maybe have a thank you message
//                    // ensure that all photos have been processed before dismissing!
//                })
            }
        })
    }
    
    // called when we are about to take photo
    func capture(_ output: AVCapturePhotoOutput, willBeginCaptureForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("will capture")
        noPendingImages = false
    }
    
    //called when processing ready
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("processed")
        if let photoData = photo.fileDataRepresentation() {
            // create uiimage from data and save it for storage later
            if let image = UIImage(data: photoData) {
                images.append(image)
            }
        } else {
            print("problem saving UIImage")
        }
        
        noPendingImages = true
    }
    
    func capture(_ output: AVCapturePhotoOutput, didFinishCaptureForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
    }

    func capture(_ output: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL, duration: CMTime, photoDisplay photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
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
