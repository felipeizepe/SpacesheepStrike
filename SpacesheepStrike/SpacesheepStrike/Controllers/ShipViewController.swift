//
//  GameViewController.swift
//  ShipSensorMovementStream
//
//  Created by Richard Vaz da Silva Netto on 31/07/18.
//  Copyright © 2018 Richard Vaz da Silva Netto. All rights reserved.
//

import UIKit
import CoreMotion
import SceneKit

class ShipViewController: UIViewController, SCNSceneRendererDelegate {

	@IBOutlet weak var scnView: SCNView!
	@IBOutlet weak var dataLabel: UILabel!
	@IBOutlet weak var sessionOwnerLabel: UILabel!
	let coreMotionServices: CoreMotionService = CoreMotionService()
	let multipeerConnectivityService: MultipeerConnectivityService = MultipeerConnectivityService()
	var ship: SCNNode?
	var sessionNode: SCNNode?
	var roll: Float = 0
	var pitch: Float = 0
	var yaw: Float = 0
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupServices()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/GameScene.scn")!
		
        // retrieve the ship node
		ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
		
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.white
    }
	
	func setupServices() {
		self.coreMotionServices.delegate = self
		self.multipeerConnectivityService.delegate = self
		
	}
	
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
	
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		
	}
}

extension ShipViewController: CoreMotionServiceDelegate {
	// Send thru the MultipeerConectivityServices the motion to the other devices
	func sendMotionData(deviceMotion: CMDeviceMotion) {
		// TODO: Delete this piece of code
		let attitude = deviceMotion.attitude
		self.dataLabel.text = "CurrentData   -   pitch: \(attitude.pitch.format(f: "0.2"))" +
		"   roll: \(attitude.roll.format(f: "0.2"))" +
		"   yaw: \(attitude.yaw.format(f: "0.2"))"
		self.multipeerConnectivityService.send(motion: attitude)
	}
}

extension ShipViewController: MultipeerConnectivityServicesDelegate {
	func showNode() {
		print("Show Node Function working")
	}
	
	func connectedDevicesChanged(manager: MultipeerConnectivityService, connectedDevices: [String]) {
		OperationQueue.main.addOperation {
			self.sessionOwnerLabel.text = "Connections: \(connectedDevices)"
		}
	}
	
	func motionChanged(manager: MultipeerConnectivityService, motion: CMAttitude?) {
		// TODO: Implement the filter for old messages to be ignored if their ∆t is too high
		self.roll = Float(motion!.roll)
		self.pitch = Float(motion!.pitch)
		self.yaw = Float(motion!.yaw)
		
		// TODO: Interpolate values for better frame rate
		OperationQueue.main.addOperation {
			self.ship?.runAction(SCNAction.rotateTo(x: CGFloat(self.roll), y: CGFloat(self.pitch), z: CGFloat(self.yaw), duration: 1/60))
		}
	}
	
	
}

















