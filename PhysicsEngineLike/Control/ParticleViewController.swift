//
//  ViewController.swift
//  PhysicsEngineLike
//
//  Created by LeeKiyang on 2016/03/25.
//  Copyright © 2016年 LeeKiyang. All rights reserved.
//

import UIKit

class ParticleViewController: UIViewController, OrientationDetectorDelegate {
    var spawnParticleTimer:Timer?
    var touchingPoint = CGPoint.zero
    let physicsEngineLike: PhysicsEngineLike = PhysicsEngineLike()
    var orientationDetector = OrientationDetector()
    override func viewDidLoad() {
        super.viewDidLoad()
        orientationDetector.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        physicsEngineLike.boundary = self.view.frame
        physicsEngineLike.gravityConstant = 600
        physicsEngineLike.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        physicsEngineLike.stop()
        physicsEngineLike.removeParticles()
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
    }
    
    @objc func spawnParticle(timer:Timer) {
        let particle = ParticleView(radius: 10)
        particle.center = touchingPoint
        view.addSubview(particle)
        physicsEngineLike.addParticle(particle)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingPoint = (touches.first?.location(in: self.view))!
        spawnParticleTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                  target: self,
                                                  selector: #selector(spawnParticle(timer:)),
                                                  userInfo: nil, repeats: true)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        spawnParticleTimer?.invalidate()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingPoint = (touches.first?.location(in: self.view))!
    }
    
    func didChangeOrientation(orientation: GravityDirection) {
        physicsEngineLike.gravityDirection = orientation
    }
}

