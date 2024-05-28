//
//  File.swift
//  
//
//  Created by Manikandan on 05/04/24.
//

import Foundation
import UIKit


extension UICollectionView{
    func registerCollectionViewCell(collectionCell: UICollectionViewCell,bundle : Bundle)
    {
        self.register(UINib(nibName: collectionCell.cellReuseIdentifier, bundle: bundle), forCellWithReuseIdentifier: collectionCell.cellReuseIdentifier);
    }
}

extension UICollectionViewCell{
    var cellReuseIdentifier : String
    {
        return NSStringFromClass(type(of: type(of: self).init()) as AnyClass).components(separatedBy: ".").last!
    }
}

