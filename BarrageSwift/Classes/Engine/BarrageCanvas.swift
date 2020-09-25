
//
//  BarrageCanvas.swift
//  BarrageSwift-Demo
//
//  Created by lishengfeng on 2020/9/24.
//  Copyright © 2020 lishengfeng. All rights reserved.
//

import Foundation
import UIKit

class BarrageCanvas: UIView {
    /// canvas是否拦截事件
    var masked: Bool = true


    var margin: UIEdgeInsets = .zero {
        didSet {
            if self.margin != oldValue {
                setNeedsLayout()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setup() {
        self.isUserInteractionEnabled = false
        self.backgroundColor = .clear
        self.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let superView = self.superview {
            let frame = superView.bounds.inset(by: self.margin)
            if frame != self.frame {
                self.frame = frame
            }
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setNeedsLayout()
        layoutIfNeeded()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if masked {
            return super.hitTest(point, with: event)
        }

        for item in self.subviews {
            let itemPoint = item.convert(point, from: self)
            if let responder = item.hitTest(itemPoint, with: event) {
                return responder
            }
        }
        return nil
    }

}
