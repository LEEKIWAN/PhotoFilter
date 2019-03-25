//
//  FilterCollectionViewCell.swift
//  PhotoFilter
//
//  Created by 이기완 on 24/03/2019.
//  Copyright © 2019 이기완. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
  
    // MARK: IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filterNameLabel: UILabel!
    
    // MARK:- Properties
//    override var isSelected: Bool {
//        didSet {
//            self.imageView.layer.borderWidth = isSelected ? 4.0 : 0
//            self.imageView.alpha = isSelected ? 0.7 : 1.0
//            super.isSelected = isSelected
//        }
//    }
    
    
    func setData(filterName: String, imageOperationQueue: OperationQueue, filteredImageChache: [String : UIImage] ) {
     
        if let filteredImage: UIImage = filteredImageChache[filterName] {
            self.imageView.image = filteredImage;
            return;
        }
        
//        imageOperationQueue.addOperation {
//            guard let inputImage: UIImage = thumbnailImage else { return }
//            guard let filter: CIFilter = CIFilter(name: filterName) else { return }
//            guard let ciImage: CIImage = CIImage(image: inputImage) else {return }
//            filter.setValue(ciImage, forKey: kCIInputImageKey)
//            guard let outputImage: CIImage = filter.outputImage else { return }
//            let context: CIContext = CIContext(options: nil)
//            guard let cgImage: CGImage = context.createCGImage(outputImage,
//                                                               from: outputImage.extent)
//                else { return }
//            let filteredImage: UIImage = UIImage(cgImage: cgImage)
//            filteredImageChache[filterName] = filteredImage
//            
//            OperationQueue.main.addOperation {
//                
//                let cellAtIndex: UICollectionViewCell? = self.collectionView?.cellForItem(at: indexPath)
//                
//                guard let cell: FilterCollectionViewCell = cellAtIndex as? FilterCollectionViewCell else { return }
//                
//                cell.imageView.image = filteredImage
//            }
//        }
    }
    
    
}

extension FilterCollectionViewCell {
    
    // MARK:- Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.filterNameLabel.layer.shadowColor = UIColor.black.cgColor
        filterNameLabel.layer.shadowRadius = 3.0
        filterNameLabel.layer.shadowOpacity = 1.0
        filterNameLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        filterNameLabel.layer.masksToBounds = false
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
        self.imageView.layer.borderWidth = 0
        self.imageView.alpha = 1.0
        self.filterNameLabel.text = nil
    }
}
