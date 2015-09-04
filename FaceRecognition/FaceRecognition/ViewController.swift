//
//  ViewController.swift
//  FaceRecognition
//
//  Created by Jan Riehn on 04/09/2015.
//  Copyright (c) 2015 jriehn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private let notificationCenter : NSNotificationCenter = NSNotificationCenter.defaultCenter()
    private let eyeRect : UILabel = UILabel(frame: UIScreen.mainScreen().bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(eyeRect)
        
        let visage = setupVisage()
        visage.beginFaceDetection()
        
        let cameraView = visage.visageCameraView
        self.view.addSubview(cameraView)
    }
    
    private func setupVisage() -> Visage {
        let visage = Visage(cameraPosition: Visage.CameraDevice.FaceTimeCamera, optimizeFor: Visage.DetectorAccuracy.HigherPerformance)
        visage.onlyFireNotificatonOnStatusChange = false
        
        NSNotificationCenter.defaultCenter().addObserverForName("visageFaceDetectedNotification", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { notification in
            
            UIView.animateWithDuration(0.5, animations: {
                self.eyeRect.alpha = 1
            })
            
            
            if let left = visage.leftEyePosition, right = visage.rightEyePosition {
                let width: CGFloat = (right.y-left.y)
                self.eyeRect.bounds = CGRect(x: left.y, y: left.x, width: width, height: 20)
            }
        })

        return visage
    }
}

