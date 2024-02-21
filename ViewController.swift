//
//  ViewController.swift
//  ARDemo
//
//  Created by Puja Kumari on 30/08/18.
//  Copyright © 2018 Puja Kumari. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let planetImageArray:[UIImage] = [UIImage(named:"earth/mercury.jpg")!,UIImage(named:"earth/venus.jpg")!,UIImage(named:"earth/earth-diffuse.jpg")!,UIImage(named:"earth/mars.jpg")!,UIImage(named:"earth/jupiter.jpg")!,UIImage(named:"earth/saturn.jpg")!,UIImage(named:"earth/uranus.jpg")!,UIImage(named:"earth/neptune.jpg")!,UIImage(named:"earth/pluto.jpg")!]
    let velocityRotation :[Int] = [25,45,30,60,90,70,55,80,110]
    let position :[Float] = [0.4,0.6,0.8,1.0,1.4,1.68,1.95,2.14,2.319]
    let sphereRadius:[Float] = [0.02,0.03,0.04,0.05,0.06,0.12,0.09,0.08,0.04]
    let text :[String] = ["Mercury","Venus","Earth","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        //Add recognizer to sceneview
        sceneView.addGestureRecognizer(tap)
        addSun()
        addOrbits()
        
    }
    
    //Method called when tap to delete planet and solar system while deleting it will play some sound
    @objc func handleTap(rec: UITapGestureRecognizer){
        if rec.state == .ended {
            let location: CGPoint = rec.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
            if !hits.isEmpty{
                sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    node.removeFromParentNode()
                    AudioPlayer.shared.playSound(.Mercury, on: sceneView.scene.rootNode)
            }
        }
    }
    }

    
    
    // addScene
    //jpg format
    func addMoon(sceneNode:SCNNode) {
        // create object
        let sceneObject = SCNSphere(radius: 0.01)
        // create material & add this to an array of SCN object
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named:"earth/moon.jpg")
        sceneObject.materials = [material]
        //create node
        let scenenode = SCNNode()
        // add object to the geometry of node ,node has properties like geometry,position etc.
        scenenode.geometry = sceneObject
        scenenode.position = SCNVector3(x:0.06,y: 0,z: 0)
        scenenode.rotation = SCNVector4Make(-0.5, -1, 0,.pi)
        sceneNode.addChildNode(scenenode)
        
    }
    
    //add scene
    func addSun(){
        // create object
        let sceneObject = SCNSphere(radius: 0.25)
        // create material & add this to an array of SCN object
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named:"earth/sun.jpg")
        sceneObject.materials = [material]
        //create node
        let scenenode = SCNNode()
        // add object to the geometry of node ,node has properties like geometry,position etc.
        scenenode.geometry = sceneObject
        scenenode.position = SCNVector3(x:0,y:-0.1,z:-3)
        addPlanets(sunNode: scenenode)
        // circular rotation
        for i in 0...8 {
          //rotateNode(node: scenenode, theta: .pi*2, with: true, duration: velocityRotation[i])
        let rotateAction = SCNAction.rotate(by: .pi , around: SCNVector3(0, 1,0), duration: TimeInterval(velocityRotation[i]) )
        let  repeataction = SCNAction.repeat(rotateAction, count: velocityRotation[i])
        scenenode.runAction(repeataction)
        }
        //add child node to root node of your view
        sceneView.scene.rootNode.addChildNode(scenenode)
        sceneView.autoenablesDefaultLighting = true
       
    }
   
    // add text to each planet to display it's name
    func centerText(node: SCNNode,i:Int) {
        let text = SCNText(string: self.text[i], extrusionDepth: 0)
        text.firstMaterial?.diffuse.contents = UIColor.red
        text.font = UIFont(name: "HelveticaNeue", size: 0.25)
        let textNode = SCNNode(geometry: text)
        textNode.position = SCNVector3(x:node.position.x - 0.1 ,y: node.position.y , z: node.position.z)
        node.addChildNode(textNode)
    }
   
    
    // add planets
    func addPlanets(sunNode:SCNNode) {
        for i in 0...8 {
            designPlanets(i:i,sunNode:sunNode)
        }
    }
   
    
    func designPlanets(i:Int,sunNode:SCNNode) {
        // create object
        let sceneObject = SCNSphere(radius: CGFloat(sphereRadius[i]))
        // create material & add this to an array of SCN object
        let material = SCNMaterial()
        material.diffuse.contents = planetImageArray[i]
        sceneObject.materials = [material]
        //create node
        let scenenode = SCNNode()
        // add object to the geometry of node ,node has properties like geometry,position etc.
        scenenode.geometry = sceneObject
        scenenode.position = SCNVector3(x:position[i],y: 0,z: 0)
        if planetImageArray[i] == UIImage(named: "earth/earth-diffuse.jpg") {
            addMoon(sceneNode: scenenode)
            let rotateAction = SCNAction.rotate(by: .pi , around: SCNVector3(0, 0,1), duration: TimeInterval(10))
            let  repeataction = SCNAction.repeat(rotateAction, count: 10)
            scenenode.runAction(repeataction)
        }
        //centerText(node: scenenode, i: i)
        if planetImageArray[i] == UIImage(named: "earth/saturn.jpg") {
            addSaturnLoop(sceneNode: scenenode)
        }
        //add child node to root node of your view
        sunNode.addChildNode(scenenode)
      
    }
   
    //add orbits
    func addOrbits(){
        for i in 0...8 {
            addOrbit(i: i)
        }
        }
    
    
    func addOrbit(i :Int) {
        // create object
        let torus = SCNTorus(ringRadius: CGFloat(position[i]), pipeRadius: 0.002)
        // create material & add this to an array of SCN object
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        torus.materials = [material]
        //create node
        let scenenode = SCNNode()
        // add object to the geometry of node ,node has properties like geometry,position etc.
        scenenode.geometry = torus
        scenenode.position = SCNVector3(x:0,y:-0.1,z:-3)
        sceneView.scene.rootNode.addChildNode(scenenode)
        sceneView.autoenablesDefaultLighting = true
    }
    
    func addSaturnLoop(sceneNode:SCNNode) {
        let box = SCNBox(width: 0.6, height: 0, length: 0.6, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named:"earth/saturn_loop.png")
        box .materials = [material]
        //create node
        let scenenode = SCNNode()
        // add object to the geometry of node ,node has properties like geometry,position etc.
        scenenode.geometry =  box
        scenenode.rotation = SCNVector4Make(-0.5, -1, 0,.pi/2)
        sceneNode.addChildNode(scenenode)
    }
 
    //  CAAnimation rotation and revolution
    private func rotateNode(node : SCNNode, theta : Double, with animation : Bool = false,duration:Int) {
        if animation {
            let rotation = CABasicAnimation(keyPath: "rotation")
            rotation.fromValue = SCNVector4Make(0,1,0,0)
            rotation.toValue = SCNVector4Make(0,1,0,Float(theta))
            rotation.duration = 25
            rotation.repeatCount = Float.infinity
            node.addAnimation(rotation, forKey: "Rotate it")
        }
        node.rotation = SCNVector4Make(0, 1, 0, Float(theta))  // along x-z plane
        print("rotating node with angle :\(theta)")
    }
    
  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    

   
   
    
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




