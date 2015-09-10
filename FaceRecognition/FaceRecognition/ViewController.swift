import UIKit
import QuartzCore
import SceneKit

class ViewController: UIViewController {
    private let notificationCenter : NSNotificationCenter = NSNotificationCenter.defaultCenter()
    
    private let screenWidth : CGFloat = 320
    private let scaleX : CGFloat = (320 / 750)
    private let scaleY : CGFloat = (568 / 1334)
    
    private let eyeRectL : UILabel = UILabel()
    private let eyeRectR : UILabel = UILabel()
    
    private var scnView : SCNView!
    private var glasses : SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Scene
        let scene = SCNScene(named: "glasses1.dae")!
        
        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        scene.rootNode.addChildNode(cameraNode)

        // Light
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // Ambient Light
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        glasses = scene.rootNode.childNodeWithName("glasses2", recursively: true)!

        scnView =  SCNView()
        scnView.scene = scene
        scnView.backgroundColor = UIColor.clearColor()
        scnView.frame = self.view.bounds
        
        let visage = setupVisage()
        let cameraView = visage.visageCameraView

        self.view.addSubview(cameraView)
        self.view.addSubview(scnView)

        self.view.addSubview(eyeRectL)
        self.view.addSubview(eyeRectR)
        
        visage.beginFaceDetection()
    }
    
    private func setupVisage() -> Visage {
        let visage = Visage(cameraPosition: Visage.CameraDevice.FaceTimeCamera, optimizeFor: Visage.DetectorAccuracy.BatterySaving)
        
        visage.onlyFireNotificatonOnStatusChange = false
        
        NSNotificationCenter.defaultCenter().addObserverForName("visageNoFaceDetectedNotification", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { notification in
            self.eyeRectL.backgroundColor = UIColor.redColor()
            self.eyeRectR.backgroundColor = UIColor.redColor()
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName("visageFaceDetectedNotification", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { notification in
            self.eyeRectL.backgroundColor = UIColor.blueColor()
            self.eyeRectR.backgroundColor = UIColor.blueColor()
            
            
            if let left = visage.leftEyePosition, right = visage.rightEyePosition {
                if (self.scnView != nil && self.glasses != nil && visage.faceAngle != nil) {
                    let projectedPoint = SCNVector3(x: Float(self.screenWidth) - Float(((left.y + right.y) / 2) * self.scaleX), y: Float(((right.x + left.x) / 2) * self.scaleY), z:Float(1 - 0.075 * ((right.y - left.y) /  self.screenWidth)))
                    
                    let unProjectedPoint = self.scnView.unprojectPoint(projectedPoint)
                    
                    self.glasses.rotation = SCNVector4(x: 0, y: 0, z: 0, w: 0)
                    
                    let xAngle = SCNMatrix4MakeRotation(-Float(M_PI / 2), 1, 0, 0)
                    let yAngle = SCNMatrix4MakeRotation(0, 0, 1, 0)
                    let zAngle = SCNMatrix4MakeRotation((Float(M_PI / 180) * Float(visage.faceAngle!)), 0, 0, 1)
                    
                    var rotationMatrix = SCNMatrix4Mult(SCNMatrix4Mult(xAngle, yAngle), zAngle)
                    
                    self.glasses.transform = SCNMatrix4Mult(rotationMatrix, self.glasses.transform)
                    
                    self.glasses.runAction(SCNAction.moveTo(unProjectedPoint, duration: 0.200))
                }
                
                self.eyeRectL.frame = CGRect(x: CGFloat(self.screenWidth - (left.y * self.scaleX)), y:left.x * self.scaleY, width: 5, height: 5)
                self.eyeRectR.frame = CGRect(x: CGFloat(self.screenWidth - (right.y * self.scaleX)), y:right.x * self.scaleY, width: 5, height: 5)
            }
            
            
            
        })
        
        return visage
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
}

