//
//  ElasticBodyViewController.swift
//  physicsenginelike
//
//  Created by 李 起揚 on 2016/05/06.
//  Copyright © 2016年 LeeKiyang. All rights reserved.
//

import UIKit

class ElasticBodyViewController: UIViewController, OrientationDetectorDelegate {
    
    let physicsEngineLike: PhysicsEngineLike = PhysicsEngineLike()
    var orientationDetector = OrientationDetector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orientationDetector.setDelegate(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        physicsEngineLike.boundary = view.frame
        physicsEngineLike.gravityConstant = 600
        physicsEngineLike.start()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        physicsEngineLike.stop()
        physicsEngineLike.removeParticles()
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
    }
    
    func didChangeOrientation(orientation: GravityDirection) {
        physicsEngineLike.gravityDirection = orientation
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let point = (touches.first?.locationInView(self.view))!
        spawn(point)
    }
    
    func spawn(point: CGPoint) {
        let radius: CGFloat = 20
        let connectionLength: CGFloat = 200
        let stiffness: CGFloat = 200
        
        let particleView1 = ParticleView(radius: radius)
        let particleView2 = ParticleView(radius: radius)
        let particleView3 = ParticleView(radius: radius)
        let particleView4 = ParticleView(radius: radius)
        let particleView5 = ParticleView(radius: radius)
        
        particleView1.center = CGPoint(x: point.x, y: point.y)
        particleView2.center = CGPoint(x: particleView1.center.x + connectionLength, y: particleView1.center.y)
        particleView3.center = CGPoint(x: particleView1.center.x, y: particleView1.center.y + connectionLength)
        particleView4.center = CGPoint(x: particleView3.center.x + connectionLength, y: particleView3.center.y)
        particleView5.center = CGPoint(x: particleView1.center.x + connectionLength/2, y: particleView2.center.y + connectionLength/2)
        
        particleView1.backgroundColor = UIColor.redColor()
        particleView2.backgroundColor = UIColor.redColor()
        particleView3.backgroundColor = UIColor.redColor()
        particleView4.backgroundColor = UIColor.redColor()
        particleView5.backgroundColor = UIColor.redColor()
        
        view.addSubview(particleView1)
        view.addSubview(particleView2)
        view.addSubview(particleView3)
        view.addSubview(particleView4)
        view.addSubview(particleView5)
        
        physicsEngineLike.addParticle(particleView1)
        physicsEngineLike.addParticle(particleView2)
        physicsEngineLike.addParticle(particleView3)
        physicsEngineLike.addParticle(particleView4)
        physicsEngineLike.addParticle(particleView5)
        
        physicsEngineLike.addConnection(particleView1, particle2: particleView2, length: connectionLength, stiffness: stiffness)
        physicsEngineLike.addConnection(particleView1, particle2: particleView3, length: connectionLength, stiffness: stiffness)
        physicsEngineLike.addConnection(particleView1, particle2: particleView5, length: connectionLength * sqrt(2) / 2, stiffness: stiffness)
        physicsEngineLike.addConnection(particleView2, particle2: particleView4, length: connectionLength, stiffness: stiffness)
        physicsEngineLike.addConnection(particleView2, particle2: particleView5, length: connectionLength * sqrt(2) / 2, stiffness: stiffness)
        physicsEngineLike.addConnection(particleView3, particle2: particleView4, length: connectionLength, stiffness: stiffness)
        physicsEngineLike.addConnection(particleView3, particle2: particleView5, length: connectionLength * sqrt(2) / 2, stiffness: stiffness)
        physicsEngineLike.addConnection(particleView4, particle2: particleView5, length: connectionLength * sqrt(2) / 2, stiffness: stiffness)

    }
}
