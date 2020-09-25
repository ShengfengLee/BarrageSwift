//
//  BarrageViewProtocol.swift
//  BarrageSwift-Demo
//
//  Created by lishengfeng on 2020/9/24.
//  Copyright © 2020 lishengfeng. All rights reserved.
//

import Foundation
import UIKit

/// UIView 弹幕协议
public protocol BarrageViewProtocol: UIView {
    func update(time: TimeInterval)
    func prepareForReuse()
    func configure(params: [String: Any])
}

public typealias BarrageClickAction = ([String: Any]) -> Void
/// Action 弹幕协议
public protocol BarrageActionProtocol {
    /// 注入点击行为
    var clickAction: BarrageClickAction { get set }
}
