//
//  ViewController.swift
//  BarrageSwift
//
//  Created by lishengfeng on 09/25/2020.
//  Copyright (c) 2020 lishengfeng. All rights reserved.
//

import UIKit
import BarrageSwift

class ViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!

    var index: Int = 0

    let renderer = BarrageRenderer()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        renderer.masked = false
        
        contentView.addSubview(renderer.view)
    }


    @IBAction func startClick(_ sender: UIButton) {
        renderer.start()
        index = 0
    }


    @IBAction func pauseClick(_ sender: UIButton) {
        renderer.pause()
    }

    @IBAction func stopClick(_ sender: UIButton) {
        renderer.stop()
    }


    @IBAction func send1Click(_ sender: UIButton) {
        sendSprite()
    }


    @IBAction func send2Click(_ sender: UIButton) {
        sendSprite()
        sendSprite()
    }


    @IBAction func send4Click(_ sender: UIButton) {
        sendSprite()
        sendSprite()
        sendSprite()
        sendSprite()
    }

    func sendSprite() {

        let walkSprite = BarrageWalkSprite { BarrageSpriteView() }
        walkSprite.viewParams["index"] = index
        walkSprite.direction = .leftToRight
        walkSprite.clickAction = { params in
            let index = params["index"] as? Int
            print("这是第\(index ?? 0)个弹幕")
        }

        index += 1
        renderer.receive(sprite: walkSprite)
    }
}

