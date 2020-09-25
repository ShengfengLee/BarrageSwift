//
//  BarrageSprite.swift
//  BarrageSwift-Demo
//
//  Created by lishengfeng on 2020/9/24.
//  Copyright © 2020 lishengfeng. All rights reserved.
//

import Foundation
import CoreGraphics
import  UIKit

class BarrageSprite {

    /// 延时, 这个是相对于rendered的绝对时间/秒
    /// 如果delay<0, 当然不会提前显示 ^ - ^
    public var delay: TimeInterval
    /// 创建的绝对时间,初始化的时候创建; 目前好像没啥用处
    public var birth: Date
    /// 时间戳,表示这个弹幕处于的时间位置;相对于时间引擎启动的时候;精灵被激活的时候生成
    public var timestamp: CFTimeInterval = 0
    public var zIndex: UInt = 0
    /// 是否有效,默认true; 当过了动画时间之后,就会被标记成false; 永世不得翻身;子类可能需要在 update(time:) 中修改 valid成员变量
    private(set) var valid: Bool = true
    /// 注入点击行为
    public var clickAction: BarrageClickAction?

    /// 输出的view,这样就不必自己再绘制图形了,并且可以使用硬件加速
    public var view: BarrageViewProtocol!
    public var viewParams = [String: Any]()
    /// 强制性大小,默认为nil,大小自适应; 否则使用mandatorySize的值来设置view大小
    public var mandatorySize: CGSize?

    private var tapGesture: UITapGestureRecognizer?
    ///当为true时，表示在本次弹幕周期内，强制将弹幕无效
    private var invalid: Bool = false
     var origin: CGPoint

    var createSpriteViewHandle: () -> BarrageViewProtocol

    init(createSpriteViewHandle: @escaping () -> BarrageViewProtocol) {
        self.createSpriteViewHandle = createSpriteViewHandle
        delay = 0
        birth = Date()
        valid = true
        origin = CGPoint(x: Double.greatestFiniteMagnitude, y: Double.greatestFiniteMagnitude)

        zIndex = 0
        invalid = false
    }

    ///更新精灵的位置
    public func update(time: TimeInterval, rect: CGRect) {
        self.valid = !self.invalid && self.valid(time: time, rect: rect)
        self.view.frame = self.rect(time: time)

        self.view.update(time: time)
    }

    public func valid(time: TimeInterval, rect: CGRect) -> Bool {
        return true
    }

    public func rect(time: TimeInterval) -> CGRect {
        return CGRect(origin: origin, size: self.size)
    }

    /// 在本次弹幕周期内，强制将弹幕无效
    public func forceInvalid() {
        self.invalid = true
    }

    //激活精灵
    public func active(sprites: [BarrageSprite], timestamp: TimeInterval, rect: CGRect) {
        self.timestamp = timestamp

        //创建弹幕view
        if self.view == nil {
            self.view = self.createSpriteViewHandle()
        }
        self.initializeViewState()

        ///复用弹幕view
        self.view.prepareForReuse()
        self.view.sizeToFit()

        ///强制设置弹幕的大小
        if let size = self.mandatorySize, size != .zero {
            self.view.frame = CGRect(origin: .zero, size: size)
        }

        self.origin = self.origin(inBounds: rect, with: sprites)
        self.view.frame = CGRect(origin: origin, size: self.size)
    }

    func deactive() {
        self.restoreViewState()
        self.invalid = false

    }

    /// 恢复view状态，将要失效时使用
    public func restoreViewState() {
        if self.clickAction != nil {
            self.view.isUserInteractionEnabled = false

            if let tap = self.tapGesture {
                self.view.removeGestureRecognizer(tap)
            }
        }
    }

    /// 初始化view状态
    public func initializeViewState() {
        self.view.frame = .zero
        self.view.configure(params: self.viewParams)

        if self.clickAction != nil {
            self.view.isUserInteractionEnabled = true
            if self.tapGesture == nil {
                self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickSpriteView))
            }
            self.view.addGestureRecognizer(self.tapGesture!)
        }
    }

    @objc func clickSpriteView() {
        self.clickAction?(self.viewParams)
    }


    ///判断新的精灵能否显示下.需要子类去override
    func canShow(inBounds rect: CGRect, with sprites: [BarrageSprite]) -> Bool {
        return true
    }

    ///设置弹幕初试位置，子类需要override
    public func origin(inBounds rect: CGRect, with sprites: [BarrageSprite]) -> CGPoint {
        return CGPoint.zero
    }

    var position: CGPoint {
        return self.view.frame.origin
    }
    var size: CGSize {
        return self.view.frame.size
    }
}
