//
//  BarrageClock.swift
//  BarrageSwift-Demo
//
//  Created by lishengfeng on 2020/9/24.
//  Copyright © 2020 lishengfeng. All rights reserved.
//

import Foundation
import CoreGraphics
import QuartzCore

class BarrageClock {

    typealias ClockBlock = (TimeInterval) -> Void
    /// 通过回调block初始化时钟,block中返回逻辑时间,其值会受到speed的影响.
    let block: ClockBlock

    ///时间流速，默认值为1，设置必须大于0，否则无效
    private(set) var speed: CGFloat = 1
    ///定时器
    private var displayLink: CADisplayLink?
    ///上一次更新时间
    private var previousDate: CFTimeInterval = 0
    ///暂停之前的时间流速
    private var pausedSpeed: CGFloat = 0
    ///是否处于启动状态
    private var launched: Bool = false
    ///逻辑时间
    private var time: TimeInterval = 0

    init(block: @escaping ClockBlock) {
        self.block = block
    }

    /// 启动时间引擎,根据刷新频率返回逻辑时间.
    public func start() {
        if displayLink == nil {
            reset()
        }

        if launched {
            speed = pausedSpeed
        }
        else {
            previousDate = CACurrentMediaTime()
            displayLink?.add(to: .main, forMode: .common)
            launched = true
        }
    }

    /// 关闭时间引擎; 一些都已结束,或者重新开始,或者归于沉寂.
    public func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    /// 暂停,相等于把speed置为0; 不过通过start可以恢复.
    public func pause() {
        speed = 0
    }

    public func set(speed: CGFloat) {
        guard speed > 0 else { return }
        self.speed = speed
        pausedSpeed = speed
    }

    private func reset() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(update))
        self.speed = 1
        self.pausedSpeed = speed
        self.launched = false
    }

    @objc func update() {
        updateTime()
        block(time)
    }

    ///更新逻辑时间系统
    private func updateTime() {
        let current = CACurrentMediaTime()
        self.time += (current - previousDate) * CFTimeInterval(speed)
        previousDate = current
    }
}
