//
//  DatePickerView.swift
//  ZYPickerView
//
//  Created by 杨志远 on 2018/1/5.
//  Copyright © 2018年 BaQiWL. All rights reserved.
//

import UIKit

public class DatePickerView: ZYPickerView {
    public typealias DateDoneAction = (Date) -> Void
    
    var dateDoneAction : DateDoneAction!
    private lazy var picker : UIDatePicker = {
        let picker = UIDatePicker()
        if #available(iOS 13.0, *) {
            picker.backgroundColor = UIColor.systemBackground
        } else {
            picker.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        return picker
    }()
    
    public static func show(mode:UIDatePicker.Mode,minDate:Date? = nil,maxDate:Date? = nil,doneAction : @escaping DateDoneAction) {
        let pickerView = DatePickerView(frame: UIScreen.main.bounds)
        pickerView.picker.minimumDate = minDate
        pickerView.picker.maximumDate = maxDate
        pickerView.picker.datePickerMode = mode
        pickerView.dateDoneAction = doneAction
        pickerView.show()
    }
    
    override public var inputView: UIView? {
        get {
            return self.picker
        }
    }
    
    override func rightButtonClicked() {
        self.hide()
        if dateDoneAction != nil {
            dateDoneAction!(self.picker.date)
        }
    }
}


