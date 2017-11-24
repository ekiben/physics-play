//
//  ViewController.swift
//  PhysicsEngineLike
//
//  Created by LeeKiyang on 2016/03/25.
//  Copyright © 2016年 LeeKiyang. All rights reserved.
//

import UIKit

class ParticleViewController: UIViewController, OrientationDetectorDelegate {
    @IBOutlet weak var stage: UIView!
    
    var spawnParticleTimer:Timer?
    var touchingPoint = CGPoint.zero
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
        for view in self.stage.subviews {
            view.removeFromSuperview()
        }
    }
    
    @objc func spawnParticle(timer:Timer) {
        let particle = ParticleView(radius: 10)
        particle.center = touchingPoint
        stage.addSubview(particle)
        physicsEngineLike.addParticle(particle)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingPoint = (touches.first?.location(in: stage))!
        spawnParticleTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                  target: self,
                                                  selector: #selector(spawnParticle(timer:)),
                                                  userInfo: nil, repeats: true)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        spawnParticleTimer?.invalidate()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingPoint = (touches.first?.location(in: stage))!
    }
    
    func didChangeOrientation(orientation: GravityDirection) {
        physicsEngineLike.gravityDirection = orientation
    }
}

