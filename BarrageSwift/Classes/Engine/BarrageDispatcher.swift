//
//  BarrageDispatcher.swift
//  BarrageSwift-Demo
//
//  Created by lishengfeng on 2020/9/24.
//  Copyright © 2020 lishengfeng. All rights reserved.
//

import Foundation


protocol BarrageDispatcherDelegate: class {
    func shouldActive(sprite: BarrageSprite) -> Bool
    func time(for dispatcher: BarrageDispatcher) -> TimeInterval

    func willActive(sprite: BarrageSprite)
    func willDeactive(sprite: BarrageSprite)
}

/// 弹幕调度器, 主要完成负载均衡的工作.
public class BarrageDispatcher {


    /// 当前活跃的精灵.
    private(set) var activeSprites = [BarrageSprite]()
    private var waitingSprites = [BarrageSprite]()
    private(set) weak var delegate: BarrageDispatcherDelegate?
    private var previousTime: TimeInterval = 0

    init() {

    }


    /// 添加精灵.
    public func add(sprite: BarrageSprite) {
        waitingSprites.append(sprite)
    }

    /// 停止当前被激活的精灵
    public func deactiveAllSprites() {
        for sprite in activeSprites {
            self.deactive(sprite: sprite)
        }
        activeSprites.removeAll()
    }


    func set(delegate: BarrageDispatcherDelegate?) {
        self.delegate = delegate
        self.previousTime = self.currentTime
    }

    public var currentTime: TimeInterval {
        return self.delegate?.time(for: self) ?? 0
    }


    private var updateIndex = 0

    ///派发精灵。每一个时间周期调用一次改方法
    public func dispatch() {

        ///性能优化，每30个时间周期（大概半秒）刷新一次即可，无需每次重复刷新，浪费性能
        updateIndex += 1
        guard updateIndex > 30 else {
            return
        }
        updateIndex = 0
        

        //将失效的精灵移除
        let willDeactives = activeSprites.filter { $0.valid == false }
        willDeactives.forEach { [weak self] (sprite) in
            self?.deactive(sprite: sprite)
        }
        activeSprites.removeAll(where: {$0.valid == false})

        //循环取出可以显示的精灵
        var i: Int = 0
        while i < waitingSprites.count {
            let sprite = waitingSprites[i]
            if self.shouldActive(sprite: sprite) {
                self.active(sprite: sprite)

                activeSprites.append(sprite)
                waitingSprites.remove(at: i)
            }
            else {
                i += 1
            }
        }

        self.previousTime = currentTime
    }

    ///判断精灵是否可以激活
    public func shouldActive(sprite: BarrageSprite) -> Bool {
        return self.delegate?.shouldActive(sprite: sprite) ?? true
    }

    /// 激活精灵
    func active(sprite: BarrageSprite) {
        self.delegate?.willActive(sprite: sprite)
    }

    /// 精灵失活
    private func deactive(sprite: BarrageSprite) {
        self.delegate?.willDeactive(sprite: sprite)
    }
}
