//
//  FilterCollectionViewController.swift
//  PhotoFilter
//
//  Created by 이기완 on 24/03/2019.
//  Copyright © 2019 이기완. All rights reserved.
//

import UIKit
import Photos

class FilterCollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK:- Properties
    var photoAsset: PHAsset? {
        didSet {
            guard let asset = photoAsset else { return }
            
            let manager: PHCachingImageManager = self.cachingImageManager
            manager.requestImage(for: asset,
                                 targetSize: CGSize(width: 200, height: 200),
                                 contentMode: PHImageContentMode.aspectFill,
                                 options: nil,
                                 resultHandler: { image, _ in
                                    self.thumbnailImage = image })
        }
    }
    
    // MARK: Privates
    private var thumbnailImage: UIImage? {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    
    private var imageFilterNames: [String] {
        return ["CIPhotoEffectChrome", "CIPhotoEffectFade", "CIPhotoEffectInstant", "CIPhotoEffectMono", "CIPhotoEffectNoir", "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer", "CISepiaTone", "CIVignette"]
    }
    
    private let cachingImageManager: PHCachingImageManager = PHCachingImageManager()
    private let imageOperationQueue: OperationQueue = OperationQueue()
    private var filteredImageChache: [String : UIImage] = [:]
}


extension FilterCollectionViewController {
    
    private func adjustFilter(name filterName: String, for indexPath: IndexPath, cell: FilterCollectionViewCell) {
        
    }
}

// MARK:- UICollectionViewDataSource
extension FilterCollectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageFilterNames.count
    }
    
}

extension FilterCollectionViewController {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FilterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! FilterCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell: FilterCollectionViewCell = cell as? FilterCollectionViewCell else { return }
        
        let filterName: String = self.imageFilterNames[indexPath.item]
        
        cell.filterNameLabel.text = filterName
        
        self.adjustFilter(name: filterName, for: indexPath, cell: cell)
    }
}

// MARK:- UICollectionViewDelegateFlowLayout
extension FilterCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let flowLayout: UICollectionViewFlowLayout =
            self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            else { return CGSize.zero}
        
        let viewSize: CGSize = self.view.frame.size
        let sectionInset: UIEdgeInsets = flowLayout.sectionInset
        let itemHeight: CGFloat = viewSize.height - sectionInset.top - sectionInset.bottom
        let itemSize = CGSize(width: itemHeight, height: itemHeight)
        
        return itemSize
    }
}

// MARK:- UICollectionViewDelegate
extension FilterCollectionViewController {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        let userInfo: [String: Any] = ["filterName" : self.imageFilterNames[indexPath.item]]
//
//        NotificationCenter.default.post(name: Notification.Name("UserDidSelectFilterNotification"), object: nil, userInfo: userInfo)
    }
}
