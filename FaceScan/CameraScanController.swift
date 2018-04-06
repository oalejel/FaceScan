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
    let snapsRequired = 10
    var noPendingImages = true
    var pendingDismiss = false
    var images: [UIImage] = []
    

    @IBOutlet weak var scanLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
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

        // setup our AV image capture environment
        do {
            let input = try AVCaptureDeviceInput(device: frontDevice)
            captureSession = AVCaptureSession()
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                imgOuput = AVCapturePhotoOutput()
                
                if self.captureSession.canAddOutput(imgOuput) {
                    self.captureSession.addOutput(imgOuput)
                    // this layer streams changes in video feed to a CALayer
                    self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                    if let layer = self.previewLayer {
                        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
                        layer.connection?.videoOrientation = .portrait
                        layer.frame = self.view.bounds
                        self.view.layer.insertSublayer(layer, at: 0)
                        self.captureSession.startRunning()
                        
                        // create a basic fade in animation
                        let fade = CABasicAnimation(keyPath: "opacity")
                        fade.fromValue = 0
                        fade.toValue = 1
                        fade.duration = 1
                        fade.isRemovedOnCompletion = false
                        layer.add(fade, forKey: "fadeIn")
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
            if self.snapCount == self.snapsRequired {
                //save our 10 images
                self.saveImageData()
                // end timer repetition
                timer.invalidate()
                
                self.dismiss(animated: true) {
                    // do any completion cleanup if needed
                    // maybe have a thank you message
                    // ensure that all photos have been processed before dismissing!
                }
            }
            
            print("snapping number \(self.snapCount)")
        })
    }
    
    // once our images [] is full, we save everything with the keychain
    func saveImageData() {
        for (index,image) in images.enumerated() {
            // iterate through the 10 images and save in keychain
            if let jpegData = UIImageJPEGRepresentation(image, 1) {
                //using a 3rd party API that simplifies keychain secure storage
                let keychain = KeychainSwift()
                keychain.set(jpegData, forKey: "faceImage_\(index)")
                //NOTE: if we need to share this data with another app,
                //we must specify the app sandboxed group
            }
        }
    }
    
    // called when we are about to take photo
    func capture(_ output: AVCapturePhotoOutput, willBeginCaptureForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("will capture")
        noPendingImages = false
    }
    
    //called when processing ready
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("processed")
        DispatchQueue.main.async {
            self.scanLabel.text = "Scan \(self.images.count + 1)/\(self.snapsRequired) complete"
        }
        
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
}
