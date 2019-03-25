//
//  AlbumCollectionViewController.swift
//  PhotoFilter
//
//  Created by 이기완 on 12/03/2019.
//  Copyright © 2019 이기완. All rights reserved.
//

import UIKit
import Photos

class AlbumCollectionViewController: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK:- Properties
    private var fetchResult: PHFetchResult<PHAsset>?
    private var assetCollectionArray: [PHAssetCollection]?
    private var albumArray: [AlbumObject] = []
    
    private let cachingImageManager: PHCachingImageManager = PHCachingImageManager()
    
    // MARK:- Life Cycle
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}


extension AlbumCollectionViewController {
    
    /// 시스템 앨범
    private var systemAlbums: [PHAssetCollection]? {
        var albumList: [PHAssetCollection] = [PHAssetCollection]()
        
        // 카메라 롤
        if let cameraRoll: PHAssetCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary, options: nil).firstObject {
            albumList.append(cameraRoll)
        }
        
        // 셀카
//        if let selfieAlbum: PHAssetCollection = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.smartAlbumSelfPortraits, options: nil).firstObject {
//            albumList.append(selfieAlbum)
//        }
        
        // 즐겨찾는 사진
        if let favoriteAlbum: PHAssetCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil).firstObject {
            albumList.append(favoriteAlbum)
        }
        return albumList
    }
    
    
    /// 사용자 생성 앨범
    private var userAlbums: [PHAssetCollection]? {
        var albumList: [PHAssetCollection] = [PHAssetCollection]()
        
        let userAlbums: PHFetchResult<PHCollection> = PHAssetCollection.fetchTopLevelUserCollections(with: nil)
        
        for index in 0 ..< userAlbums.count {
            if let collection: PHAssetCollection =
                userAlbums.object(at: index) as? PHAssetCollection {
                albumList.append(collection)
            }
        }
        
        return albumList
    }
}

extension AlbumCollectionViewController  {
    
    // MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestAlbumAuth()
        PHPhotoLibrary.shared().register(self)
    }
}


extension AlbumCollectionViewController {
    
    /// 시스템 앨범 + 사용자 앨범 불러오기
    private func loadAllAlbums() {
        self.fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        
        guard let systemAlbums = self.systemAlbums else { return }
        guard let userAlbums = self.userAlbums else { return }
        
        let albumList: [PHAssetCollection] = systemAlbums + userAlbums
        
        // 에셋이 존재하는 에셋 컬렉션만 필터링
        self.assetCollectionArray = albumList.filter { (collection: PHAssetCollection) -> Bool in
            PHAsset.fetchAssets(in: collection, options: nil).count > 0
        }
        
        self.createAlbumsArray()
        
        OperationQueue.main.addOperation {
            self.collectionView?.reloadData()
        }
    }
    
    private func createAlbumsArray() {
        for collectionData in self.assetCollectionArray! {
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: collectionData, options: nil)
            
            let numFormatter : NumberFormatter = NumberFormatter();
            numFormatter.numberStyle = NumberFormatter.Style.decimal
            let count: Int = fetchResult.count
            let countText: String = numFormatter.string(from: NSNumber(value: count))!
            
            let album = AlbumObject()
            album.fetchResult = fetchResult
            album.title = collectionData.localizedTitle
            album.imageTotalCount = countText
            
            self.albumArray.append(album)
        }
    }
}

extension AlbumCollectionViewController {
    
    /// 사진첩 접근 권한 확인
    private func requestAlbumAuth() {
        switch PHPhotoLibrary.authorizationStatus() {
        case PHAuthorizationStatus.authorized:      self.loadAllAlbums()
        case PHAuthorizationStatus.denied:          print("사진첩 접근 거부됨")
        case PHAuthorizationStatus.restricted:      print("사집첩 접근 불가")
        case PHAuthorizationStatus.notDetermined:
            PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) in
                switch status {
                case PHAuthorizationStatus.authorized:
                    self.loadAllAlbums()
                case PHAuthorizationStatus.denied:
                    print("사진첩 접근 거부됨")
                default:
                    break
                }
            }
        }
    }
}

extension AlbumCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK:- UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetCollectionArray?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AlbumCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as! AlbumCollectionViewCell
        let album = self.albumArray[indexPath.row]
        
        cell.setData(album: album, cachingImageManager: self.cachingImageManager)

        return cell
    }
    
    // MARK : - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  30
        let collectionViewSize = collectionView.frame.size.width - padding
        let width = collectionViewSize / 2
        
        let height = width * 1.257
        
        return CGSize(width: width, height: height)
    }
    
    // MARK : - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AlbumCollectionViewCell
        
        let storyboard = UIStoryboard(name: "PhotoCollectionViewController", bundle: Bundle.main)
        let viewController = storyboard.instantiateInitialViewController() as! PhotoCollectionViewController
        
        guard let assetCollection: PHAssetCollection = self.assetCollectionArray?[indexPath.item] else { return }
        
        viewController.title = cell.titleLabel?.text
        
        let fetchOptions: PHFetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        OperationQueue().addOperation {
            viewController.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
            viewController.assetCollection = assetCollection            
        }
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}


extension AlbumCollectionViewController: PHPhotoLibraryChangeObserver {
    
    // MARK:- Reset Cache
    private func resetCachedAssets() {
        self.cachingImageManager.stopCachingImagesForAllAssets()
    }
    
    // MARK:- PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fetchResult = self.fetchResult else { return }
        
        DispatchQueue.main.sync {
            guard let _ = changeInstance.changeDetails(for: fetchResult)
                else { return }
            
            self.resetCachedAssets()
            self.loadAllAlbums()
            self.collectionView?.reloadData()
        }
    }
}
