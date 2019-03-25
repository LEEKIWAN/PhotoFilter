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
