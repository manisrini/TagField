//
//  TagFieldComponentViewModel.swift
//  FacilioFramework
//
//  Created by Manikandan on 03/04/24.
//

import Foundation

public struct Tag{
    public var id : Int
    public var text : String
    public var displayName : String?
    public var isHighlight : Bool
    public var showCloseBtn : Bool
    
    public init(id : Int,text: String,displayName : String? = nil,isHighlight: Bool = false,showCloseBtn : Bool = true) {
        self.id = id
        self.text = text
        self.displayName = displayName
        self.isHighlight = isHighlight
        self.showCloseBtn = showCloseBtn
    }
}

public class TagFieldComponentViewModel
{
    var masterTags : [Tag] = []
    public var disableTextField : Bool
    var tags : [Tag] = []
    public var textFieldId : Int = 0
    public var truncateViewWhenFieldNotFocused : Bool = true
    
    var numberOfItems : Int = 0
    var isTextFieldFocused : Bool = false
    var currentTypedText : String = ""
    var didSomeOtherAction : Bool = false

    public init(tags: [Tag] = [],disableTextField : Bool = false,truncateViewWhenFieldNotFocused: Bool = true) {
        self.masterTags = tags
        self.tags = tags
        self.disableTextField = disableTextField
        self.truncateViewWhenFieldNotFocused = truncateViewWhenFieldNotFocused
        
        if !isTextFieldFocused && masterTags.count > 1{
            self.tags.removeSubrange(1 ..< masterTags.count)
            self.tags.append(Tag(id: 2, text: "+\(masterTags.count - 1)"))
        }
    }
    
    public func setTags(tag : [Tag]){
        self.tags = tag
        self.masterTags = tag
    }
    
    func createViewModel(index : Int) -> TagModel
    {
        if index < self.tags.count{
            if isTextFieldFocused{
                let tag = self.tags[index]
                return TagModel(text: getDisplayName(tag: tag), isHighlight: tag.isHighlight,showCloseBtn: true)
            }else{
                if index == 1{
                    let tagModel = TagModel(text: "+\(self.masterTags.count - 1)",showCloseBtn: false)
                    return tagModel
                }else{
                    let tag = self.tags[index]
                    return TagModel(text: getDisplayName(tag: tag), isHighlight: tag.isHighlight, showCloseBtn: tag.showCloseBtn)
                }
            }
            
        }
        return TagModel(text: "")
    }
    
    func getTagValue(index : Int) -> String{
        if index < self.tags.count{
            
            if self.truncateViewWhenFieldNotFocused{
                if isTextFieldFocused{
                    let tag = self.tags[index]
                    return getDisplayName(tag: tag)
                }else{
                    if index == 1{
                        return "+\(self.masterTags.count - 1)"
                    }else{
                        let tag = self.tags[index]
                        return getDisplayName(tag: tag)
                    }
                }
            }else{
                let tag = self.tags[index]
                return getDisplayName(tag: tag)
            }
        }
        return ""
    }
    
    func showCloseBtn(index : Int) -> Bool{
        if index < self.tags.count{
            let tag = self.tags[index]
            return tag.showCloseBtn
        }
        return false
    }
    
    func getDisplayName(tag : Tag) -> String{
        if let _displayName = tag.displayName{
            return _displayName
        }else{
            return tag.text
        }
    }
}
