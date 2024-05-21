//
//  FCTagCollectionViewCell.swift
//  FacilioFramework
//
//  Created by Manikandan on 03/04/24.
//

import UIKit
import SnapKit

struct TagModel{
    var text : String
    var isHighlight : Bool = false
    var showCloseBtn : Bool = true
    var bgColor : UIColor = CommonUtils.shared.hexStringToUIColor(hex: "F5F5F5")
    var textColor : UIColor = CommonUtils.shared.hexStringToUIColor(hex: "283648")
    var borderColor : UIColor = CommonUtils.shared.hexStringToUIColor(hex: "DBDBDB")
    var highlightBgColor : UIColor = CommonUtils.shared.hexStringToUIColorWithOpacity(hex: "F5F5F5", opacity: 0.5)
    var highlightTextColor : UIColor = CommonUtils.shared.hexStringToUIColorWithOpacity(hex: "283648", opacity: 0.5)
    var highlightBorderColor : UIColor = CommonUtils.shared.hexStringToUIColorWithOpacity(hex: "DBDBDB", opacity: 0.5)
}

class FCTagCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tagViewContainer : UIView!
    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var closeImageView: UIImageView!
    @IBOutlet weak var closeImageViewContainer: UIView!
    @IBOutlet weak var closeImageViewContainerWidth: NSLayoutConstraint!
    
    var didTapBtn : (()->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        addStyles()
        addTapGestureForImage()
    }
    
    func addStyles(){
        self.textLbl.font = UIFont(name: "Roboto", size: 12)
        self.closeImageView.image?.withRenderingMode(.alwaysTemplate)
        self.closeImageView.tintColor = CommonUtils.shared.hexStringToUIColor(hex: "283648")
    }
    
    @IBAction func closeBtnAction(_ sender: Any) {
        self.didTapBtn?()
    }
    
    func addTapGestureForImage(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        self.closeImageViewContainer.isUserInteractionEnabled = true
        self.closeImageViewContainer.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didTapImage(){
        self.didTapBtn?()
    }

    func config(viewModel : TagModel)
    {
        
        if viewModel.showCloseBtn{
            self.closeImageViewContainer.isHidden = false
            self.closeImageViewContainerWidth.constant = 25
            self.closeImageViewContainer.backgroundColor = viewModel.bgColor
            self.closeImageView.backgroundColor = viewModel.bgColor
            self.closeImageView.tintColor = viewModel.textColor
        }else{
            self.closeImageViewContainer.isHidden = true
            self.closeImageViewContainerWidth.constant = 0
        }
        
        if viewModel.isHighlight{
            self.tagViewContainer.backgroundColor = viewModel.highlightBgColor
            self.textLbl.textColor = viewModel.highlightTextColor
            self.tagViewContainer.borderColor = viewModel.highlightBgColor
            self.closeImageViewContainer.backgroundColor = viewModel.highlightBgColor
            self.closeImageView.backgroundColor = viewModel.highlightBgColor
            self.closeImageView.tintColor = viewModel.highlightTextColor
        }else{
            self.tagViewContainer.backgroundColor = viewModel.bgColor
            self.textLbl.textColor = viewModel.textColor
            self.tagViewContainer.borderColor = viewModel.borderColor
        }
        
        self.tagViewContainer.borderWidth = 1
        self.tagViewContainer.cornerRadius = 4
        self.textLbl.text = viewModel.text
    }

}
