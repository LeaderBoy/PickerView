//
//  ZYPickerView.swift
//  ZYPickerView
//
//  Created by 杨志远 on 2017/12/29.
//  Copyright © 2017年 BaQiWL. All rights reserved.
//

import UIKit


public class ZYPickerView: UIView {
    public typealias DoneAction = ([PickerIndexPath]) -> Void
    
    public struct PickerIndexPath {
        public var component : Int
        public var row : Int
        public var value : String
    }
    
    var doneAction : DoneAction?
    var selectedValue : [PickerIndexPath]!
    
    static let screenFrame = UIScreen.main.bounds
    fileprivate static let toolBarH    : CGFloat = 44.0
    fileprivate static var screenWidth : CGFloat {
        return screenFrame.width
    }
    fileprivate static var screenHeight : CGFloat {
        return ZYPickerView.screenFrame.height
    }
    
    fileprivate lazy var toolBar : UIToolbar = {
        let tool = UIToolbar(frame: CGRect(x: 0, y:0, width: ZYPickerView.screenWidth, height: ZYPickerView.toolBarH))
        let leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(leftButtonClicked))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(rightButtonClicked))
        tool.tintColor = UIColor.black
        tool.items = [leftBarButtonItem,space,rightBarButtonItem]
        return tool
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.show()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: 点击事件
    @objc func leftButtonClicked() {
        self.hide()
    }
    
    @objc func rightButtonClicked() {
        
    }
    
    override public var inputAccessoryView: UIView! {
        get {
            return self.toolBar
        }
    }
    
    override public var canBecomeFirstResponder: Bool {
        return true
    }
    
    override  public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let inputView = self.inputView,let touch = touches.first else { return}
        let inputY = ZYPickerView.screenFrame.height - inputView.frame.size.height - ZYPickerView.toolBarH
        let touchY = touch.location(in: self).y
        if touchY < inputY {
            self.hide()
        }
    }
    
}

extension ZYPickerView {
    func show() {
        guard let keyWindow = UIApplication.shared.keyWindow else{
            return
        }
        keyWindow.addSubview(self)
        self.becomeFirstResponder()
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = UIColor(white: 0, alpha: 0.2)
        }
    }
    
    @objc func hide() {
        self.resignFirstResponder()
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundColor = UIColor.clear
        }) { (_) in
            self.removeFromSuperview()
        }
    }
}


