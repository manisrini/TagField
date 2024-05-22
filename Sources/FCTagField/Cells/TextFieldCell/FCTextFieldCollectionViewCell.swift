//
//  FCTextFieldCollectionViewCell.swift
//  
//
//  Created by Manikandan on 05/04/24.
//

import UIKit

@objc protocol FCTextFieldCellDelegate : AnyObject{
    func didClickEmptyBackSpace()
    func didTypeText()
    func typedText(text : String)
    func isFieldFocused(focus : Bool)
    func didGetFrame(origin : CGPoint)
    
}

public struct TxtFieldTheme
{
    var fontSize : CGFloat = 14
    var fontFamily : String = "Roboto"
    var fontColor : UIColor = CommonUtils.shared.hexStringToUIColor(hex: "283648")
    var placeHolderColor : UIColor = CommonUtils.shared.hexStringToUIColor(hex: "607796")
    var placeHolderText : String = "Enter here"
}

class FCTextFieldCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var textFieldContainer: UIView!
    
    weak var delegate : FCTextFieldCellDelegate?
    var txtViewWidth : CGFloat = 120
    var txtViewHeight : CGFloat = 40
    var txtView : BackSpaceListenerTextView?
    var id : Int = 0
    var theme : TxtFieldTheme = TxtFieldTheme()    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func setTheme(theme : TxtFieldTheme){
        self.theme = theme
    }
    
    public func clearTextContents(){
        self.txtView?.clearTextContents()
    }
        
    func addTextField(){
        
        let txtView = BackSpaceListenerTextView(frame: CGRect(x: 0, y: 0, width: txtViewWidth, height: txtViewHeight), textContainer: nil)
        txtView.setTheme(theme: theme)
        self.txtView = txtView
        txtView.onBackspace = { [weak self] tap in
            if tap{
                self?.delegate?.didClickEmptyBackSpace()
            }
        }
        txtView.getFrame = { [weak self] origin in
            self?.delegate?.didGetFrame(origin: origin)
        }
        
        txtView.isFieldFocused = { [weak self] focus in
            self?.delegate?.isFieldFocused(focus: focus)
        }
        
        txtView.didTypeText = { [weak self] in
            self?.delegate?.didTypeText()
        }
        
        txtView.typedText = { [weak self] text in
            self?.delegate?.typedText(text: text)
        }
        
        txtView.frame = CGRect(x: 0, y: 0, width: textFieldContainer.frame.width, height: textFieldContainer.frame.height)
        self.textFieldContainer.addSubview(txtView)
        
        txtView.snp.makeConstraints { make in
            make.left.equalTo(textFieldContainer)
            make.right.equalTo(textFieldContainer)
            make.centerY.equalTo(textFieldContainer.snp.centerY)
        }
    }

}

class BackSpaceListenerTextView: UITextView, UITextViewDelegate {
    var onBackspace: ((Bool) -> Void)?
    var didTypeText: (() -> ())?
    var typedText: ((String) -> ())?
    var isFieldFocused: ((Bool) -> ())?
    var getFrame : ((CGPoint)->())?
    var id: Int = 0
    var theme: TxtFieldTheme = TxtFieldTheme()
    var didSomeOtherAction: Bool = false
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.delegate = self
        self.spellCheckingType = .no
        self.autocorrectionType = .no
        self.setUpTextView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpTextView() {
        self.textContainer.maximumNumberOfLines = 1
        self.textContainer.lineBreakMode = .byTruncatingTail
        self.textContainer.lineFragmentPadding = 0
        self.isScrollEnabled = false
        self.textContainerInset = .zero
        self.textContainer.lineFragmentPadding = 0
        self.textContainerInset = UIEdgeInsets.zero
        self.textContainer.lineBreakMode = .byTruncatingTail
        self.textContainer.maximumNumberOfLines = 1
        self.textContainer.widthTracksTextView = true
        self.textContainer.heightTracksTextView = true
        self.textContainer.layoutManager?.allowsNonContiguousLayout = false
        
        self.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        self.textContainer.lineFragmentPadding = 0
        
        self.font = UIFont(name: theme.fontFamily, size: theme.fontSize)
        self.textColor = theme.fontColor
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveSomeOtherAction), name: Notification.Name("someOtherAction"), object: nil)
    }
    
    @objc func didReceiveSomeOtherAction() {
        self.didSomeOtherAction = true
    }
    
    func setTheme(theme: TxtFieldTheme) {
        self.theme = theme
        self.setStyles()
    }
    
    func clearTextContents() {
        self.text = ""
    }
    
    private func setStyles() {
        self.font = UIFont(name: theme.fontFamily, size: theme.fontSize)
        if self.text?.isEmpty ?? false{
            self.text = theme.placeHolderText
            self.textColor = theme.placeHolderColor
        }else{
            self.textColor = theme.fontColor
        }

    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.typedText?(textView.text ?? "")
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == theme.placeHolderColor {
            textView.text = nil
            textView.textColor = theme.fontColor
        }
        
        let textViewTopLeft = textView.convert(CGPoint.zero, to: nil)
        let yCoordinate = textViewTopLeft.y
        self.getFrame?(CGPoint(x: self.frame.origin.x, y: yCoordinate))
        self.isFieldFocused?(true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = theme.placeHolderText
            textView.textColor = theme.placeHolderColor
        }

        self.isFieldFocused?(false)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.didTypeText?()
        return true
    }
    
    override func deleteBackward() {
        onBackspace?(text?.isEmpty == true)
        super.deleteBackward()
    }
    
}
