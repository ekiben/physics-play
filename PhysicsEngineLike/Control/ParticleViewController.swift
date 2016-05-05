//
//  ViewController.swift
//  PhysicsEngineLike
//
//  Created by LeeKiyang on 2016/03/25.
//  Copyright © 2016年 LeeKiyang. All rights reserved.
//

import UIKit

class ParticleViewController: UIViewController, OrientationDetectorDelegate {
    var spawnParticleTimer:NSTimer?
    var touchingPoint = CGPointZero
    let physicsEngineLike: PhysicsEngineLike = PhysicsEngineLike()
    var orientationDetector = OrientationDetector()
    override func viewDidLoad() {
        super.viewDidLoad()
        orientationDetector.setDelegate(self)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        physicsEngineLike.boundary = self.view.frame
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
    
    func spawnParticle(timer:NSTimer) {
        let particle = ParticleView(radius: 10)
        particle.center = touchingPoint
        view.addSubview(particle)
        physicsEngineLike.addParticle(particle)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchingPoint = (touches.first?.locationInView(self.view))!
        spawnParticleTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ParticleViewController.spawnParticle(_:)), userInfo: nil, repeats: true)
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        spawnParticleTimer?.invalidate()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchingPoint = (touches.first?.locationInView(self.view))!
    }
    
    func didChangeOrientation(orientation: GravityDirection) {
        physicsEngineLike.gravityDirection = orientation
    }
}

