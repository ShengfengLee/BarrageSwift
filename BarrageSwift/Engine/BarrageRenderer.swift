//
//  BarrageRenderer.swift
//  BarrageSwift-Demo
//
//  Created by lishengfeng on 2020/9/24.
//  Copyright © 2020 lishengfeng. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class BarrageRenderer: NSObject {


    var time: TimeInterval = 0

    private var dispatcher: BarrageDispatcher?
    private(set) var canvas: BarrageCanvas
    private(set) var startTime: Date?
    private(set) var pausedTime: Date?
    private var pausedDuration: TimeInterval = 0

    private lazy var clock: BarrageClock = {
         let clock = BarrageClock(block: { [weak self] (time) in
             self?.time = time
             self?.update()
         })
         return clock
     }()

    override init() {
        self.canvas = BarrageCanvas()
    }



    public func start() {
        canvas.setNeedsLayout()
        if startTime == nil {
            startTime = Date()
            dispatcher = BarrageDispatcher()
            dispatcher?.set(delegate: self)
        }
        else if let time = pausedTime {
            self.pausedDuration += Date().timeIntervalSince(time)
        }
        pausedTime = nil
        clock.start()
    }

    public func pause() {
        // 没有运行, 则暂停无效
        if startTime == nil {
            return
        }

        //正在暂停
        if let time = pausedTime {
            pausedDuration += Date().timeIntervalSince(time)
        }
        else {// 当前没有暂停
            clock.pause()
            pausedTime = Date()
        }
    }

    public func stop() {
        startTime = nil
        clock.stop()
        pausedDuration = 0
    }

    private func update() {
        guard let dispatcher = dispatcher else { return }
        dispatcher.dispatch()

        for sprite in dispatcher.activeSprites {
            sprite.update(time: time, rect: self.canvas.bounds)
        }
    }


    public func receive(sprite: BarrageSprite) {
        DispatchQueue.main.async {
            // 如果没有启动,则抛弃接收弹幕
            if self.startTime == nil {
                return
            }
            self.dispatcher?.add(sprite: sprite)
        }
    }


    ///获取当前暂停时长
    func getPausedDuration() -> TimeInterval {
        if let time = pausedTime {
            return Date().timeIntervalSince(time) + pausedDuration
        }
        return 0
    }

    /// 获取当前时间
    var currentTime: TimeInterval {
        guard let start = startTime else { return 0}
        let currentTime = Date().timeIntervalSince(start) - pausedDuration
        return currentTime
    }


    var canvasMargin: UIEdgeInsets {
        set {
            canvas.margin = newValue
        }
        get {
            return canvas.margin
        }
    }
    var masked: Bool {
        set {
            canvas.masked = newValue
        }
        get {
            return canvas.masked
        }
    }
    var speed: CGFloat {
        set {
            clock.set(speed: newValue)
        }
        get {
            return clock.speed
        }
    }
}


extension BarrageRenderer: BarrageDispatcherDelegate {

    func shouldActive(sprite: BarrageSprite) -> Bool {
        //暂停状态
        if pausedTime != nil {
            return false
        }

        guard let dispatcher = dispatcher else { return false }
        let canShow = sprite.canShow(inBounds: canvas.bounds, with: dispatcher.activeSprites)
        return canShow
    }
    
    func time(for dispatcher: BarrageDispatcher) -> TimeInterval {
        return self.currentTime
    }

    func willActive(sprite: BarrageSprite) {
        guard let dispatcher = dispatcher else { return }
        sprite.active(sprites: dispatcher.activeSprites, timestamp: self.time, rect: canvas.bounds)
        canvas.addSubview(sprite.view)
    }

    func willDeactive(sprite: BarrageSprite) {
        sprite.view.removeFromSuperview()
        sprite.deactive()
    }
}
