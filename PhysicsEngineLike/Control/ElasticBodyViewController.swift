//
//  ElasticBodyViewController.swift
//  physicsenginelike
//
//  Created by 李 起揚 on 2016/05/06.
//  Copyright © 2016年 LeeKiyang. All rights reserved.
//

import UIKit

class ElasticBodyViewController: UIViewController, OrientationDetectorDelegate {
    @IBOutlet weak var stage: UIView!
    
    let physicsEngineLike: PhysicsEngineLike = PhysicsEngineLike()
    var orientationDetector = OrientationDetector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orientationDetector.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        physicsEngineLike.boundary = stage.bounds
        physicsEngineLike.gravityConstant = 600
        physicsEngineLike.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        physicsEngineLike.stop()
        physicsEngineLike.removeParticles()
        for view in stage.subviews {
            view.removeFromSuperview()
        }
    }
    
    func didChangeOrientation(orientation: GravityDirection) {
        physicsEngineLike.gravityDirection = orientation
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = (touches.first?.location(in: self.view))!
        spawn(point: point)
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
        
        particleView1.backgroundColor = UIColor.red
        particleView2.backgroundColor = UIColor.red
        particleView3.backgroundColor = UIColor.red
        particleView4.backgroundColor = UIColor.red
        particleView5.backgroundColor = UIColor.red
        
        stage.addSubview(particleView1)
        stage.addSubview(particleView2)
        stage.addSubview(particleView3)
        stage.addSubview(particleView4)
        stage.addSubview(particleView5)
        
        physicsEngineLike.addParticle(particleView1)
        physicsEngineLike.addParticle(particleView2)
        physicsEngineLike.addParticle(particleView3)
        physicsEngineLike.addParticle(particleView4)
        physicsEngineLike.addParticle(particleView5)
        
        physicsEngineLike.addConnection(particle1: particleView1, particle2: particleView2, length: connectionLength, stiffness: stiffness)
        physicsEngineLike.addConnection(particle1: particleView1, particle2: particleView3, length: connectionLength, stiffness: stiffness)
        physicsEngineLike.addConnection(particle1: particleView1, particle2: particleView5, length: connectionLength * sqrt(2) / 2, stiffness: stiffness)
        physicsEngineLike.addConnection(particle1: particleView2, particle2: particleView4, length: connectionLength, stiffness: stiffness)
        physicsEngineLike.addConnection(particle1: particleView2, particle2: particleView5, length: connectionLength * sqrt(2) / 2, stiffness: stiffness)
        physicsEngineLike.addConnection(particle1: particleView3, particle2: particleView4, length: connectionLength, stiffness: stiffness)
        physicsEngineLike.addConnection(particle1: particleView3, particle2: particleView5, length: connectionLength * sqrt(2) / 2, stiffness: stiffness)
        physicsEngineLike.addConnection(particle1: particleView4, particle2: particleView5, length: connectionLength * sqrt(2) / 2, stiffness: stiffness)

    }
}
