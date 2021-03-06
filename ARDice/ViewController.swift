//
//  ViewController.swift
//  ARDice
//
//  Created by Ebubechukwu Dimobi on 26.07.2020.
//  Copyright © 2020 blazeapps. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        //
        //        //add light
        
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
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
    
    //MARK: - to detect touches and handle touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first{
               addDice(atLocation: hitResult)
                
                
              
                
            }
        }
        
        
    }
    
    //MARK: - add dice to plane
    func addDice( atLocation location: ARHitTestResult){
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                      
                      if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
                          
                          diceNode.position = SCNVector3(
                              location.worldTransform.columns.3.x,
                              location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                              location.worldTransform.columns.3.z
                          )
                          
                          diceArray.append(diceNode)
                          
                          sceneView.scene.rootNode.addChildNode(diceNode)
                          
                          //to rotatae dice
                         roll(dice: diceNode)
                      }
        
        
    }
    
    func rollALL() {
        if !diceArray.isEmpty{
            
            for dice in diceArray {
                roll(dice: dice)
            }
            
        }
        
    }
    
    func roll(dice: SCNNode){
        //to rotatae dice
        let randomX = Float(Int.random(in: 1...4)) * (Float.pi/2)
        let randomZ = Float(Int.random(in: 1...4)) * (Float.pi/2)
        
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * 5),
                y: 0,
                z: CGFloat(randomZ * 5),
                duration: 0.5
        )
    )
        
    }
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty{
            for dice in diceArray{
                dice.removeFromParentNode()
            }
        }
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        
        rollALL()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollALL()
    }
    
    
    //MARK: - add a plane ARSCNViewDelegate Method
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if anchor is ARPlaneAnchor{
            print("plane detected")
            
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
        } else {
            return
        }
    }
    
}
