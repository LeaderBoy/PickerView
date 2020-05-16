//
//  StringPickerView.swift
//  ZYPickerView
//
//  Created by 杨志远 on 2018/1/5.
//  Copyright © 2018年 BaQiWL. All rights reserved.
//

import UIKit

/// 关联的数据类型
public struct AssociatedData {
    var key: String
    var valueArray: [String]?
    public init (key: String, valueArray: [String]? = nil) {
        self.key = key
        self.valueArray = valueArray
    }
}

public class StringPickerView: ZYPickerView {
    public typealias AssociatedRowDataType = [[AssociatedData]]
    
    public enum PickerDataSourceType {
        case singleRowData(_ : [String],defaultIndex: Int?)
        case multiRowData(_ : [[String]],defaultIndexs: [Int]?)
        case associatedRowData(_ : AssociatedRowDataType,defaultIndexs: [Int]?)
    }
    
    lazy var isSingleRowData = false
    lazy var isMultiRowData  = false
    lazy var isAssociatedRowData = false
    
    var singleRowData   : [String]! {
        didSet {
            isSingleRowData = true
            self.picker.reloadAllComponents()
        }
    }
    var multiRowData    : [[String]]! {
        didSet {
            isMultiRowData = true
            self.picker.reloadAllComponents()
        }
    }
    
    var associatedRowData : AssociatedRowDataType! {
        didSet {
            isAssociatedRowData = true
            associatedRowDataCount = associatedRowData.count
            var key = ""
            self.selectedValue = associatedRowData.enumerated().map({ (arg) -> PickerIndexPath in
                let (component, rowData) = arg
                
                if component == 0 {
                    key = rowData[0].key
                }else{
                    guard let values = rowData.first(where: {$0.key == key}) else{
                        return PickerIndexPath(component: component, row: 0, value: "")
                    }
                    if values.valueArray != nil && values.valueArray!.count >= 1 {
                        key = values.valueArray![0]
                    }else{
                        key = ""
                    }
                }
                return PickerIndexPath(component: component, row: 0, value: key)
            })
            
            self.picker.reloadAllComponents()
        }
    }
    var associatedRowDataCount : Int!
    
    fileprivate lazy var picker : UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        return picker
    }()
    
    override public var inputView: UIView? {
        get {
            return self.picker
        }
    }
    //MARK: Show
    public static func show(dataSource : PickerDataSourceType,doneAction : @escaping DoneAction) {
        let frame = UIScreen.main.bounds
        switch dataSource {
        case .singleRowData(let single,let index):
            let stringPickerView = StringPickerView(frame: frame)
            stringPickerView.show(singleRowData: single, default: index, doneAction: doneAction)
        case .multiRowData(let multi,let indexs) :
            let stringPickerView = StringPickerView(frame: frame)
            stringPickerView.show(mutliRowData: multi, default: indexs, doneAction: doneAction)
        case .associatedRowData(let associated,let indexs):
            let stringPickerView = StringPickerView(frame: frame)
            stringPickerView.show(associatedRowData: associated, default: indexs, doneAction: doneAction)
        }
        
    }
    //MARK: 单列
    func show(singleRowData:[String],default index : Int? = nil,doneAction : @escaping DoneAction) {
        assert(!singleRowData.isEmpty, "数组为空")
        let hasDefaultIndex : Bool = index != nil
        if hasDefaultIndex {
            assert(singleRowData.count > index!,"默认的index超出了dataSource数组的总个数")
        }
        self.doneAction = doneAction
        self.singleRowData = singleRowData
        self.selectedValue = hasDefaultIndex ?
            [PickerIndexPath(component: 0,row: index!,value: singleRowData[index!])]
            :
            [PickerIndexPath(component: 0, row: 0, value: singleRowData[0])]
        self.picker.selectRow(index ?? 0, inComponent: 0, animated: true)
    }
    //MARK: 多列
    func show(mutliRowData:[[String]],default index : [Int]? ,doneAction : @escaping DoneAction) {
        assert(!mutliRowData.isEmpty, "数组为空")
        let hasDefaultIndex : Bool = index != nil
        
        if hasDefaultIndex {
            assert(mutliRowData.count == index!.count,"默认的indexs与mutliRowData数组的总个数不一致")
        }
        self.multiRowData = mutliRowData
        self.doneAction = doneAction
        self.selectedValue = hasDefaultIndex ?
            index!.enumerated().map({ (component,i) -> PickerIndexPath in
                assert(multiRowData[component].count > i, "默认值导致数组越界")
                self.picker.selectRow(i, inComponent: component, animated: true)
                return  PickerIndexPath( component: component,row: i,value: multiRowData[component][i])
            })
            :
            multiRowData.enumerated().map({ (arg) -> PickerIndexPath in
                let (component, dataArray) = arg
                return PickerIndexPath(component: component, row: 0, value: dataArray[0])
            })
    }
    //MARK: 多关联
    func show(associatedRowData:AssociatedRowDataType,default index : [Int]? ,doneAction : @escaping DoneAction) {
        assert(!associatedRowData.isEmpty, "数组为空")
        let hasDefaultIndex : Bool = index != nil
        self.associatedRowData = associatedRowData
        
        if hasDefaultIndex {
            assert(associatedRowDataCount == index!.count,"默认的index与associatedRowData数组的总个数不一致")
        }
        self.doneAction = doneAction
        
        
        if hasDefaultIndex {
            _ = index!.enumerated().map({ (component,row) -> PickerIndexPath in
                let title = currentTitleFor(row, in: component)
                self.selectedValue[component].component = component
                self.selectedValue[component].row = row
                if title != nil {
                    self.selectedValue[component].value = title!
                }else{
                    self.selectedValue[component].value = ""
                }
                reloadPicker(row, in: component)
                return PickerIndexPath(component: component, row: row, value: title ?? "")
            })
        }
        
    }
    //MARK:完成按钮点击事件
    override func rightButtonClicked() {
        self.hide()
        if doneAction != nil {
            doneAction!(selectedValue)
        }
    }
    
    func refreshLaterFor(_ row :Int, in component : Int) {
        for com in ((component+1)..<associatedRowDataCount) {
            let preKey = previousKeyFor(row, in: com)
            let valueArray = fetchValueArray(use: preKey, for: com)
            if valueArray != nil  && valueArray!.count > 0 {
                self.selectedValue[com].value = valueArray![0]
            }else{
                self.selectedValue[com].value = ""
            }
            self.selectedValue[com].row = 0
            self.selectedValue[com].component = com
            reloadPicker(in: com)
        }
    }
    
    
    func reloadPicker(_ row: Int? = nil,in component: Int) {
        self.picker.reloadComponent(component)
        self.picker.selectRow(row ?? 0, inComponent: component, animated: true)
    }
    
    func previousKeyFor(_ row : Int ,in component : Int) -> String? {
        if component == 0 {
            assert(associatedRowData[0].count > row, "row超出了associatedRowData[0]的个数")
            return associatedRowData[component][row].key
        }
        if selectedValue.count > component-1 {
            return selectedValue[component-1].value
        }else{
            return nil
        }
    }
    
    func currentTitleFor(_ row : Int,in component : Int) -> String? {
        assert(associatedRowDataCount > component, "component应小于associatedRowData的个数")
        let preKey = previousKeyFor(row, in: component)
        if component == 0 {
            return preKey
        }
        let valueArray = fetchValueArray(use: preKey, for: component)
        if valueArray != nil  && valueArray!.count > row {
            return valueArray![row]
        }else{
            return nil
        }
    }
    
    func fetchRowData(use preKey : String?,for component : Int) -> AssociatedData? {
        let array = associatedRowData[component]
        guard let rowData = array.first(where: { $0.key == preKey}) else {
            return nil
        }
        return rowData
    }
    
    func fetchValueArray(use preKey : String?,for component : Int) -> [String]? {
        guard let rowData = fetchRowData(use: preKey, for: component) else { return nil }
        return rowData.valueArray
    }
    
}
//MARK: UIPickerViewDataSource,UIPickerViewDelegate
extension StringPickerView : UIPickerViewDataSource,UIPickerViewDelegate {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if isSingleRowData {
            return 1
        }else if isMultiRowData {
            return multiRowData.count
        }else if isAssociatedRowData{
            return associatedRowDataCount
        }
        return 0
    }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if isSingleRowData {
            return singleRowData.count
        }else if isMultiRowData{
            return multiRowData.count
        }else if isAssociatedRowData {
            if component == 0 {
                return associatedRowData[component].count
            }else {
                let key = self.selectedValue[component-1].value
                let array = associatedRowData[component]
                guard let rowData = array.first(where: { $0.key == key}) else {
                    return 0
                }
                if rowData.valueArray != nil {
                    return rowData.valueArray!.count
                }
                return 0
            }
        }
        return 0
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if isSingleRowData {
            if singleRowData.count > row {
                return singleRowData[row]
            }else{
                return nil
            }
        }else if isMultiRowData{
            if multiRowData.count > component && multiRowData[component].count > row{
                return multiRowData[component][row]
            }else{
                print("rowData.count 少于等于 component")
                return nil
            }
        }else if isAssociatedRowData{
            return currentTitleFor(row, in: component)
        }
        return nil
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedValue[component].component = component
        selectedValue[component].row = row
        
        if isSingleRowData {
            selectedValue[component].value = singleRowData[row]
        }else if isMultiRowData{
            selectedValue[component].value = multiRowData[component][row]
        }else if isAssociatedRowData {
            selectedValue[component].value = currentTitleFor(row, in: component) ?? ""
            if component < associatedRowDataCount - 1 {
                refreshLaterFor(row,in : component)
            }
        }
    }
    
    //end
}

