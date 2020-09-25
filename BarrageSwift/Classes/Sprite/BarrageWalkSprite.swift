//
//  BarrageWalkSprite.swift
//  BarrageSwift-Demo
//
//  Created by lishengfeng on 2020/9/24.
//  Copyright © 2020 lishengfeng. All rights reserved.
//

import Foundation
import CoreGraphics

class BarrageWalkSprite: BarrageSprite {
    enum Direction {
        case rightToLeft
        case leftToRight
//        case topToBottom
//        case bottomToTop
    }

    public var speed: CGFloat = 0.2
    fileprivate(set) var destination: CGPoint = .zero
    /// 轨道数量
    var trackNumber: UInt = 2
    ///该精灵在哪一条跑道，编号从0开始
    var track: UInt = 0
    ///同一跑道精灵间最小距离
    var minDistance: CGFloat = 44

    ///跑道的高度
    var trackHeight: CGFloat = 55

    var direction: Direction = .rightToLeft

    ///判断新的精灵能否显示下
    override func canShow(inBounds rect: CGRect, with sprites: [BarrageSprite]) -> Bool {
        let array = sprites.filter { $0 is BarrageWalkSprite }
        guard let walkSprites = array as? [BarrageWalkSprite] else { return false }

//        guard walkSprites.count > 0 else { return true }

        //遍历每一个跑道
        for track in 0..<trackNumber {

            //找到当前跑到最后面一个精灵的位置
            var lastDistance: CGFloat = 0
            switch self.direction {
            case .rightToLeft:
                lastDistance = 0
            case .leftToRight:
                lastDistance = rect.size.width
            }

            for sprite in walkSprites {
                if sprite.track == track {

                    switch self.direction {
                    case .rightToLeft:
                        if sprite.view.frame.maxX > lastDistance {
                            lastDistance = sprite.view.frame.maxX
                        }
                    case .leftToRight:
                        if sprite.view.frame.minX < lastDistance {
                            lastDistance = sprite.view.frame.minX
                        }
                    }


                }
            }

            //判断当前跑道能否放得下,可以放下的话，直接返回true
            switch self.direction {
            case .rightToLeft:
                if lastDistance + minDistance < rect.size.width {
                    self.track = track  //设置精灵所在的跑道
                    return true
                }
            case .leftToRight:
                if lastDistance - minDistance > 0 {
                    self.track = track  //设置精灵所在的跑道
                    return true
                }
            }


        }
        return false
    }

    ///设置精灵初试位置
    override func origin(inBounds rect: CGRect, with sprites: [BarrageSprite]) -> CGPoint {


        let trackFrom = CGFloat(track) * trackHeight


        switch self.direction {
        case .rightToLeft:
            self.origin.x = rect.size.width
            destination.x = 0
        case .leftToRight:
            self.origin.x = 0 - self.size.width
            destination.x = rect.size.width
        }

        self.origin.y = trackFrom + (trackHeight - self.size.height) / 2
        destination.y = self.origin.y

        return origin
    }

    override func valid(time: TimeInterval, rect: CGRect) -> Bool {
        switch self.direction {
        case .rightToLeft:

            if self.view.frame.maxX > 0 {
                return true
            }
        case .leftToRight:
            if self.view.frame.minX < rect.size.width {
                return true
            }
        }


        return false
    }

    override func rect(time: TimeInterval) -> CGRect {
        let x = self.destination.x - self.origin.x
        let duration = time - self.timestamp
        let postion = CGPoint(x: self.origin.x + CGFloat(duration) * speed * x,
                              y: self.origin.y)
        return CGRect(origin: postion, size: self.size)
    }

    
}

extension BarrageWalkSprite {
    /// 估算精灵的剩余存活时间
    func estimateActiveTime() -> TimeInterval {
        var activeDistance: CGFloat = 0
        activeDistance = self.position.x - destination.x

        return TimeInterval(activeDistance / self.speed)
    }
}
