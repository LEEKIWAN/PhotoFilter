//
//  AlbumCollectionViewCell.swift
//  PhotoFilter
//
//  Created by 이기완 on 13/03/2019.
//  Copyright © 2019 이기완. All rights reserved.
//

import UIKit
import Photos


class AlbumCollectionViewCell: UICollectionViewCell {
   
    // MARK:- Properties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    // MARK:- Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.layer.cornerRadius = 5.0
    }
    
//    func configureCell(collectionData: PHAssetCollection, cachingImageManager: PHCachingImageManager) {
//        let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: collectionData, options: nil)
//        guard let asset: PHAsset = fetchResult.lastObject else { return }
//
//        self.titleLabel.text = collectionData.localizedTitle
//        
//        //
//        let numFormatter : NumberFormatter = NumberFormatter();
//        numFormatter.numberStyle = NumberFormatter.Style.decimal
//        let count: Int = fetchResult.count
//        let countText: String = numFormatter.string(from: NSNumber(value: count))!
//        self.countLabel.text = countText
//        
//        //
//        cachingImageManager.requestImage(for: asset, targetSize: self.imageView.frame.size, contentMode: PHImageContentMode.aspectFill, options: nil, resultHandler: { (image, _) in
//            self.imageView.image = image
//        })
//        
//    }
    
    func setData(album: AlbumObject, cachingImageManager: PHCachingImageManager) {
        self.countLabel.text = album.imageTotalCount
        self.titleLabel.text = album.title
        
        if album.coverImage == nil {
            cachingImageManager.requestImage(for: (album.fetchResult?.lastObject!)!, targetSize: self.imageView.frame.size, contentMode: PHImageContentMode.aspectFill, options: nil, resultHandler: { (image, _) in
                album.coverImage = image!
                self.imageView.image = album.coverImage
            })
        }
        else {
            self.imageView.image = album.coverImage
        }
        
        
        
        
    }
}
