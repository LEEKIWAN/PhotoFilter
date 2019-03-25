//
//  PhotoCollectionViewController.swift
//  PhotoFilter
//
//  Created by 이기완 on 20/03/2019.
//  Copyright © 2019 이기완. All rights reserved.
//

import UIKit
import Photos


class PhotoCollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK:- Properties
    var fetchResult: PHFetchResult<PHAsset>? {
        didSet {
            OperationQueue.main.addOperation {
                self.collectionView.dataSource = self
                self.collectionView.delegate = self
                self.collectionView?.reloadData()
            }
        }
    }
    
    var assetCollection: PHAssetCollection?
    
    // MARK: Privates
    private let cachingImageManager: PHCachingImageManager = PHCachingImageManager()
    
    // MARK:- Life Cycle
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }    
}

// MARK:- UICollectionViewDataSource
extension PhotoCollectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        
        let asset: PHAsset = (self.fetchResult?.object(at: indexPath.item))!
        cell.setData(asset: asset, cachingImageManager: self.cachingImageManager)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "PhotoEditViewController", bundle: Bundle.main)
        let viewController = storyboard.instantiateInitialViewController() as! PhotoEditViewController
        
        viewController.asset = self.fetchResult?.object(at: indexPath.item)
        viewController.assetCollection = self.assetCollection
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}


// MARK:- UICollectionViewDelegateFlowLayout
extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let flowLayout: UICollectionViewFlowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize.zero}
        
        let numberOfCellsInRow: CGFloat = 4
        let viewSize: CGSize = self.view.frame.size
        let sectionInset: UIEdgeInsets = flowLayout
            .sectionInset
        
        let interitemSpace: CGFloat = flowLayout.minimumInteritemSpacing * (numberOfCellsInRow - 1)
        
        var itemWidth: CGFloat
        itemWidth = viewSize.width - sectionInset.left - sectionInset.right - interitemSpace
        itemWidth /= numberOfCellsInRow
        
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        return itemSize
    }
}

extension PhotoCollectionViewController {
    private func updateCollectionView(with changes: PHFetchResultChangeDetails<PHAsset>) {
        guard let collectionView = self.collectionView else { return }
        
        // 업데이트는 삭제, 삽입, 다시 불러오기, 이동 순으로 진행합니다
        if let removed: IndexSet = changes.removedIndexes, removed.count > 0 {
            collectionView.deleteItems(at: removed.map({
                IndexPath(item: $0, section: 0)
            }))
        }
        
        if let inserted: IndexSet = changes.insertedIndexes, inserted.count > 0 {
            collectionView.insertItems(at: inserted.map({
                IndexPath(item: $0, section: 0)
            }))
        }
        
        if let changed: IndexSet = changes.changedIndexes, changed.count > 0 {
            collectionView.reloadItems(at: changed.map({
                IndexPath(item: $0, section: 0)
            }))
        }
        
        changes.enumerateMoves { fromIndex, toIndex in
            collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0), to: IndexPath(item: toIndex, section: 0))
        }
    }
}

// MARK:- PHPhotoLibraryChangeObserver
extension PhotoCollectionViewController: PHPhotoLibraryChangeObserver {
    
    private func resetCachedAssets() {
        self.cachingImageManager.stopCachingImagesForAllAssets()
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fetchResult: PHFetchResult<PHAsset> = self.fetchResult
            else { return }
        
        guard let changes: PHFetchResultChangeDetails<PHAsset> =
            changeInstance.changeDetails(for: fetchResult)
            else { return }
        
        DispatchQueue.main.sync {
            self.resetCachedAssets()
            self.fetchResult = changes.fetchResultAfterChanges
            
            if changes.hasIncrementalChanges {
                self.updateCollectionView(with: changes)
            } else {
                self.collectionView?.reloadData()
            }
        }
    }
}

extension PhotoCollectionViewController {
    
    // MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.shared().register(self)
    }
    
}

extension PhotoCollectionViewController {
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        guard let destination = segue.destination as? PhotoViewController,
//            let cell: PhotoCollectionViewCell = sender as? PhotoCollectionViewCell,
//            let indexPath: IndexPath = collectionView?.indexPath(for: cell)
//            else { return }
//        
//        destination.asset = fetchResult?.object(at: indexPath.item)
//        destination.assetCollection = self.assetCollection
    }
}
