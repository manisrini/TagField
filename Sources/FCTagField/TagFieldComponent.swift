//
//  TagFieldComponent.swift
//  FacilioFramework
//
//  Created by Manikandan on 03/04/24.
//

import Foundation
import UIKit

public protocol TagFieldComponentDelegate : AnyObject{
    func didGetInstance(instance : TagFieldComponent)
    func handleTypedText(text : String)
    func didChangeHeight(size : CGSize)
    func didGetError(error : String)
    func didRemoveTag(removedTag : Tag?,tags : [Tag])
    func didGetFrame(origin : CGPoint)
}

public class TagFieldComponent : UIView
{
    
    @IBOutlet weak var tagCollectionView: UICollectionView!
    
    public weak var delegate : TagFieldComponentDelegate?
    var _textFieldInstance : FCTextFieldCollectionViewCell?
    static let nibName = "TagFieldComponent"
    var viewModel : TagFieldComponentViewModel?
    
    var didClickBackSpace : Bool = false
    var cellTag : Int = 0
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        onLoad()
        
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        onLoad()
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle.module
        let nib = UINib(nibName: TagFieldComponent.nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    private func onLoad(){
        setUpCollectionView()
        registerCells()
        addContentChangeObserver()
        addObservers()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveSomeOtherAction), name: Notification.Name("someOtherAction"), object: nil)
    }
    
    @objc func didReceiveSomeOtherAction() {
        self.viewModel?.didSomeOtherAction = true
    }

    
    func addContentChangeObserver(){
        self.tagCollectionView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    public override  func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let newSize = change?[.newKey] as? CGSize {
                print("CollectionView Size -> \(newSize)")
                self.delegate?.didChangeHeight(size: newSize)
            }
        }
    }
    
    private func setUpCollectionView(){
        if let alignedFlowLayout = tagCollectionView.collectionViewLayout as? AlignedCollectionViewFlowLayout{
            alignedFlowLayout.horizontalAlignment = .left
            alignedFlowLayout.minimumLineSpacing = 5
            self.tagCollectionView.collectionViewLayout = alignedFlowLayout
        }
    }
    
    private func registerCells(){
        let bundle = Bundle.module
        self.tagCollectionView.registerCollectionViewCell(collectionCell: FCTagCollectionViewCell(),bundle: bundle)
        self.tagCollectionView.registerCollectionViewCell(collectionCell: FCTextFieldCollectionViewCell(),bundle: bundle)
    }
    
    public func config(viewModel : TagFieldComponentViewModel){
        self.viewModel = viewModel
        self.tagCollectionView.dataSource = self
        self.tagCollectionView.delegate = self
    }
    
    public func reloadTags(viewModel : TagFieldComponentViewModel){
        self.delegate?.didGetInstance(instance: self)
        self.viewModel = viewModel
        self.clearText()
        self.tagCollectionView.reloadData()
    }
    
    public func disableTextField(_ disable : Bool){
        self.viewModel?.disableTextField = disable
    }
    
    public func didSomeOtherAction(){
        self.viewModel?.didSomeOtherAction = true
    }
    
//    public func removeAllTags(){
//        if let _viewModel = viewModel{
//            var indicesToDelete = [IndexPath]()
//            for index in 0 ..< _viewModel.masterTags.count {
//                indicesToDelete.append(IndexPath(row: index, section: 0))
//            }
//            _viewModel.tags.removeAll()
//            _viewModel.masterTags.removeAll()
//            
//            self.tagCollectionView.deleteItems(at: indicesToDelete)
//
//        }
//
//    }
    
    public func appendNewTag(tag : Tag){
        if let _viewModel = viewModel{
            _viewModel.masterTags.append(tag)
            _viewModel.tags.append(tag)
            self.clearText()
            self.focusTextField()
            self.tagCollectionView.insertItems(at: [IndexPath(item: _viewModel.tags.count - 1, section: 0)])
        }
    }
    
    public func getMentionedTags() -> [Tag]{
        return self.viewModel?.masterTags ?? []
    }
    
    public func clearText(){
        self.viewModel?.currentTypedText = ""
        self._textFieldInstance?.clearTextContents()
    }
}

extension TagFieldComponent : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let _viewModel = viewModel{
            
            /* if indexPath.section == 0{ //Tags
             if let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FCTagCollectionViewCell", for: indexPath) as? FCTagCollectionViewCell{
             tagCell.config(viewModel: _viewModel.createViewModel(index: indexPath.row))
             return tagCell
             }
             }else{ ///TextField
             if let textFieldCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FCTextFieldCollectionViewCell", for: indexPath) as? FCTextFieldCollectionViewCell{
             textFieldCell.delegate = self
             textFieldCell.id = _viewModel.textFieldId
             self._textFieldInstance = textFieldCell
             textFieldCell.addTextField()
             return textFieldCell
             }
             }*/
            
            
            if indexPath.row == _viewModel.numberOfItems - 1 && !_viewModel.disableTextField{ //last item
                
                if let textFieldCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FCTextFieldCollectionViewCell", for: indexPath) as? FCTextFieldCollectionViewCell{
                    textFieldCell.delegate = self
                    textFieldCell.id = _viewModel.textFieldId
                    self._textFieldInstance = textFieldCell
                    textFieldCell.addTextField()
                    
                    /*if _viewModel.truncateViewWhenFieldNotFocused{
                     if _viewModel.isTextFieldFocused{
                     focusTextField()
                     }
                     }else{
                     focusTextField()
                     }*/
                    return textFieldCell
                }
            }else{
                if indexPath.row <= _viewModel.tags.count - 1{
                    if let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FCTagCollectionViewCell", for: indexPath) as? FCTagCollectionViewCell{
                        
                        tagCell.didTapBtn = { [weak self] in
                            var indicesToDelete = [IndexPath]()
                            
                            for index in 0 ..< _viewModel.masterTags.count {
                                indicesToDelete.append(IndexPath(row: index, section: 0))
                            }
                            _viewModel.tags.removeAll()
                            _viewModel.masterTags.remove(at: indexPath.row)
                            
                            self?.tagCollectionView.deleteItems(at: indicesToDelete)
                            
                            for (index,tag) in _viewModel.masterTags.enumerated() {
                                _viewModel.tags.append(tag)
                                self?.tagCollectionView.insertItems(at: [IndexPath(item: index, section: 0)])
                            }
                        }
                        
                        tagCell.config(viewModel: _viewModel.createViewModel(index: indexPath.row))
                        return tagCell
                    }
                }
            }
        }
        return UICollectionViewCell()
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _viewModel = viewModel{
            
            /*if section == 0{  ///Tag section
             if _viewModel.isTextFieldFocused{
             return _viewModel.tags.count
             }else{
             if _viewModel.tags.count >= 2{
             return 2
             }else{
             return  _viewModel.tags.count //1
             }
             }
             }
             else{ ///TextFieldSection
             return 1
             }*/
            
            if _viewModel.truncateViewWhenFieldNotFocused{
                if _viewModel.isTextFieldFocused{
                    _viewModel.numberOfItems =  _viewModel.disableTextField ? _viewModel.tags.count : _viewModel.tags.count + 1
                    return _viewModel.numberOfItems
                }
                else{
                    if _viewModel.tags.count >= 2{
                        _viewModel.numberOfItems = _viewModel.disableTextField ?  2 : 3
                        return _viewModel.numberOfItems
                    }else{
                        _viewModel.numberOfItems =  _viewModel.disableTextField ? _viewModel.tags.count : _viewModel.tags.count + 1
                        return _viewModel.numberOfItems
                    }
                }
            }else{
                _viewModel.numberOfItems = _viewModel.tags.count + 1
                return _viewModel.numberOfItems
            }
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        /*if let _viewModel = viewModel{
         if indexPath.section == 0{
         if let font = UIFont(name: "Roboto", size: 12){
         let tagValue = _viewModel.getTagValue(index: indexPath.row)
         let fontAttributes = [NSAttributedString.Key.font: font]
         let size = (tagValue as NSString).size(withAttributes: fontAttributes)
         return CGSize(width: size.width + 10, height: 30)
         
         }
         }else{
         return CGSize(width: 120, height: 40)
         }
         }*/
        if let _viewModel = viewModel{
            if indexPath.row == _viewModel.numberOfItems - 1 && !_viewModel.disableTextField{
                return CGSize(width: 120, height: 40)
            }else{ ///load a tag with +count (only 2 items )
                if let font = UIFont(name: "Roboto", size: 12){
                    let tagValue = _viewModel.getTagValue(index: indexPath.row)
                    let fontAttributes = [NSAttributedString.Key.font: font]
                    let size = (tagValue as NSString).size(withAttributes: fontAttributes)
                    if _viewModel.showCloseBtn(index: indexPath.row){
                        return CGSize(width: size.width + 35, height: 30)
                    }else{
                        return CGSize(width: size.width + 15, height: 30)
                    }
                    
                }
            }
        }
        return CGSize()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension TagFieldComponent : FCTextFieldCellDelegate
{
    func didGetFrame(origin: CGPoint) {
        self.delegate?.didGetFrame(origin: origin)
    }
    
    func isFieldFocused(focus: Bool) {
        
        
        if focus{
            self.delegate?.didGetInstance(instance: self)
        }
        
        if let _viewModel = viewModel{
            
            _viewModel.didSomeOtherAction = false
            
            if focus != _viewModel.isTextFieldFocused{
                if _viewModel.truncateViewWhenFieldNotFocused{
                    
                    if focus{
                        _viewModel.isTextFieldFocused = true
                        if _viewModel.tags.count > 1{ //Expand the tag view
                            self.tagCollectionView.collectionViewLayout.invalidateLayout()
                            //                            reloadSectionAt(sectionToReload: 0)
                            reloadCollectionViewExceptLastCell()
                        }
                    }else{
                        if _viewModel.currentTypedText.isWhiteSpace(){
                            _viewModel.isTextFieldFocused = false
                            if _viewModel.tags.count > 1{ //Truncate the tag view
                                self.tagCollectionView.collectionViewLayout.invalidateLayout()
                                //                                reloadSectionAt(sectionToReload: 0)
                                reloadCollectionViewExceptLastCell()
                            }
                        }
                        
                        else{
                            didThrowError()
                        }
                    }
                    
                }
                else{
                    _viewModel.isTextFieldFocused = focus
                    if !focus{
                        if !_viewModel.currentTypedText.isWhiteSpace(){
                            didThrowError()
                        }
                    }
                }
            }
        }
    }
    
    func didThrowError(){
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            if !(self.viewModel?.didSomeOtherAction ?? true){
                self.delegate?.didGetError(error: "Please Enter a Valid Address")
                self.focusTextField()
            }
//        }
    }
    
    private func resetCellTag(){
        self.cellTag = 0
    }
    
    private func focusTextField(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
            self._textFieldInstance?.txtView?.becomeFirstResponder()
        }
    }
    
    func typedText(text: String) {
        
        self.viewModel?.currentTypedText = text
        
        if let _specialCharacter = self.viewModel?.specialCharacter{
            if let tag = self.viewModel?.createNewTag(text: text,specialCharacter : _specialCharacter){
                self.appendNewTag(tag: tag)
            }
        }else{
            self.delegate?.handleTypedText(text: text)
        }
        
        if let _viewModel = viewModel{
            if !_viewModel.currentTypedText.isWhiteSpace(){
                resetHighlightedItem()
            }
        }
    }
    
    func resetHighlightedItem(){
        if let _viewModel = viewModel{
            if _viewModel.tags.count > 0{
                
                if didClickBackSpace{
                    self.didClickBackSpace = false
                    var tempTags : [Tag] = []
                    
                    for (index,tag) in _viewModel.tags.enumerated(){
                        if index == _viewModel.tags.count - 1{
                            tempTags.append(Tag(id: tag.id,text: tag.text,displayName: tag.displayName,isHighlight: false))
                        }
                        else{
                            tempTags.append(tag)
                        }
                    }
                    _viewModel.tags = tempTags
                    
                    DispatchQueue.main.async {
                        self.reloadCellAtIndex(indexPath: IndexPath(row: _viewModel.tags.count - 1, section: 0))
                    }
                }
            }
        }
    }
    
    func didTypeText() { ///reset the highlighted item

    }
    
    func didClickEmptyBackSpace() {
        
        if let _viewModel = viewModel{
            
            if _viewModel.tags.count > 0{ /// remove the last one
                if didClickBackSpace{
                    
                    let indexToDelete = IndexPath(item: _viewModel.masterTags.count - 1, section: 0)
                    let removedTag = _viewModel.masterTags.last
                    _viewModel.tags.removeLast()
                    _viewModel.masterTags.removeLast()
                    self.delegate?.didRemoveTag(removedTag: removedTag, tags: _viewModel.masterTags)
                    
                    self.didClickBackSpace = false
                    self.tagCollectionView.collectionViewLayout.invalidateLayout()
                    
                    DispatchQueue.main.async {
                        self.tagCollectionView.deleteItems(at: [indexToDelete])
                    }
                    
                }else{ ///highlight the last one
                    self.didClickBackSpace = true
                    var tempTags : [Tag] = []
                    
                    for (index,tag) in _viewModel.tags.enumerated(){
                        if index == _viewModel.tags.count - 1{
                            tempTags.append(Tag(id: tag.id, text: tag.text,displayName: tag.displayName,isHighlight: true))
                        }
                        else{
                            tempTags.append(tag)
                        }
                    }
                    
                    _viewModel.tags = tempTags
                    DispatchQueue.main.async {
                        self.reloadCellAtIndex(indexPath: IndexPath(row: _viewModel.tags.count - 1, section: 0))
                    }
                }
            }
            
        }
    }
    
    func reloadCellAtIndex(indexPath : IndexPath){
        self.tagCollectionView.reloadItems(at: [indexPath])
    }
    
    func reloadSectionAt(sectionToReload : Int){
        self.tagCollectionView.reloadSections(IndexSet(integer: sectionToReload))
    }
    
    func reloadCollectionViewExceptLastCell() {
        
        if let _viewModel = viewModel{
            
            if _viewModel.isTextFieldFocused{
                if _viewModel.masterTags.count > 1{
                    let indicesToDelete = [IndexPath(item: 0, section: 0),IndexPath(item: 1, section: 0)]
                    
                    _viewModel.tags.removeAll()
                    self.tagCollectionView.deleteItems(at: indicesToDelete)
                    
                    for index in 0 ..< _viewModel.masterTags.count{
                        _viewModel.tags.insert(_viewModel.masterTags[index], at: index)
                        self.tagCollectionView.insertItems(at: [IndexPath(item: index, section: 0)])
                    }
                }
                
            }else{
                if _viewModel.masterTags.count > 1{
                    var indicesToDelete = [IndexPath]()
                    
                    for index in 0 ..< _viewModel.masterTags.count {
                        //remove all indexes except firstIndex, LastIndex
                        indicesToDelete.append(IndexPath(row: index, section: 0))
                    }
                    _viewModel.tags.removeSubrange(0..<_viewModel.masterTags.count)
                    self.tagCollectionView.deleteItems(at: indicesToDelete)
                    
                    if let firstTag = _viewModel.masterTags.first{
                        _viewModel.tags.append(Tag(id: 1, text: firstTag.text,displayName: firstTag.displayName,showCloseBtn: false))
                        self.tagCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
                    }
                    
                    _viewModel.tags.append(Tag(id: 2, text: "+\(_viewModel.masterTags.count - 1)",showCloseBtn: false))
                    self.tagCollectionView.insertItems(at: [IndexPath(item: 1, section: 0)])
                }
            }
        }
    }
}
