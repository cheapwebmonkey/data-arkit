//
//  ViewController.swift
//  data_overlay
//
//  Created by Margeaux Spring on 11/25/18.
//  Copyright © 2018 Margeaux Spring. All rights reserved.

//  NOTE not all iOS devices support ARkit- the XR in the emulator,
//  for example does not, so you'll need to include 'arkit' for the
//  UIRequiredDeviceCapabilities key in the Info.plist

import UIKit
import SceneKit
import ARKit
import Vision
import RxSwift
import RxCocoa
import SwiftyJSON
import VisualRecognitionV3
import PKHUD




class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        //adds plane detection configuration to horizontal
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
}


// MARK: — Face detections
private func faceObservation() -> Observable<[(observation: VNFaceObservation, image: CIImage, frame: ARFrame)]> {
    return Observable<[(observation: VNFaceObservation, image: CIImage, frame: ARFrame)]>.create{ observer in
        guard let frame = self.sceneView.session.currentFrame else {
            print("No frame available")
            observer.onCompleted()
            return Disposables.create()
        }
        
        // Create and rotate image
        let image = CIImage.init(cvPixelBuffer: frame.capturedImage).rotate
        let facesRequest = VNDetectFaceRectanglesRequest { request, error in
            guard error == nil else {
                print("Face request error: \(error!.localizedDescription)")
                observer.onCompleted()
                return
}

            guard let observations = request.results as? [VNFaceObservation] else {
                print("No face observations")
                observer.onCompleted()
                return
}


            // Map response
            let response = observations.map({ (face) -> (observation: VNFaceObservation, image: CIImage, frame: ARFrame) in
                return (observation: face, image: image, frame: frame)
            })
            observer.onNext(response)
            observer.onCompleted()
        }
        try? VNImageRequestHandler(ciImage: image).perform([facesRequest])
        return Disposables.create()
    }
}
