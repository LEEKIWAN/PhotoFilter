//
//  PhotoCollectionViewCell.swift
//  PhotoFilter
//
//  Created by 이기완 on 20/03/2019.
//  Copyright © 2019 이기완. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK:- Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.imageView.layer.cornerRadius = 5.0
    }
    
//    func configureCell(collectionData: PHAssetCollection, cachingImageManager: PHCachingImageManager) {
//        
//    }
}
