//
//  BarrageSpriteView.swift
//  BarrageSwift-Demo
//
//  Created by lishengfeng on 2020/9/24.
//  Copyright © 2020 lishengfeng. All rights reserved.
//

import UIKit

class BarrageSpriteView: UIView {

    let height: CGFloat = 36
    let contentHeight: CGFloat = 30
    let labelLeftMargin: CGFloat = 10
    let labelRightMargin: CGFloat = 10

    ///背景渐变色
//    var gradientLayer: CAGradientLayer!
    var avatarBoarderImageView: UIImageView!
    var avatarImageView: UIImageView!
    var titleLabel: UILabel!


    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        //渐变色
//        gradientLayer = CAGradientLayer()
//        gradientLayer.locations = [0, 1]
//        gradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
//        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
//        gradientLayer.masksToBounds = true
//        gradientLayer.masksToBounds = true
//        self.layer.addSublayer(gradientLayer)

        self.backgroundColor = .green

        avatarImageView = UIImageView()
        avatarImageView.backgroundColor = .clear
        avatarImageView.contentMode = .scaleToFill
        avatarImageView.layer.masksToBounds = true
        self.addSubview(avatarImageView)

        avatarBoarderImageView = UIImageView()
        avatarBoarderImageView.backgroundColor = .clear
        self.addSubview(avatarBoarderImageView)

        titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        self.addSubview(titleLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()


        self.avatarBoarderImageView.frame = CGRect(x: 0,
                                                   y: 0,
                                                   width: height,
                                                   height: height)

        let x = (height - contentHeight) / 2
        self.avatarImageView.frame = CGRect(x: x,
                                            y: x,
                                            width: contentHeight,
                                            height: contentHeight)
        self.avatarImageView.layer.cornerRadius = contentHeight / 2

        self.titleLabel.frame = CGRect(x: height + labelLeftMargin,
                                       y: 0,
                                       width: self.bounds.size.width - height - labelLeftMargin - labelRightMargin,
                                       height: height)

//        self.gradientLayer.frame = CGRect(x: x,
//                                          y: x,
//                                          width: self.bounds.size.width - x,
//                                          height: contentHeight)
//        self.gradientLayer.cornerRadius = contentHeight / 2
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)

        var width: CGFloat = 0
        width += height

        let titleSize = self.titleLabel.sizeThatFits(CGSize(width: 10000, height: 18))
        width += labelLeftMargin
        width += titleSize.width
        width += labelRightMargin

        return CGSize(width: width, height: height)
    }
}

extension BarrageSpriteView: BarrageViewProtocol {
    func prepareForReuse() {
//        self.gradientLayer.isHidden = true
    }

    func configure(params: [String: Any]) {
        avatarImageView.image = UIImage.actions

        let index = params["index"] as? Int
        //消息内容
        let text = "这是第\(index ?? 0)个弹幕"
        self.titleLabel.text = text

//        self.gradientLayer.isHidden = false
        //渐变色


//        self.gradientLayer.colors = [UIColor.green.cgColor,
//                                     UIColor.blue.cgColor]
        self.avatarBoarderImageView.image = UIImage(named: "barrage_avatar_boarder_all")

        self.setNeedsLayout()
    }

    func update(time: TimeInterval) {

    }
}

