//
//  PhotoEditViewController.swift
//  PhotoFilter
//
//  Created by 이기완 on 24/03/2019.
//  Copyright © 2019 이기완. All rights reserved.
//

import UIKit
import Photos

class PhotoEditViewController: UIViewController {
    // MARK:- Properties
    var asset: PHAsset?
    var assetCollection: PHAssetCollection?
    
    // MARK: IBOutlets
    @IBOutlet weak var assetImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var resetFilterButton: UIBarButtonItem!
    @IBOutlet weak var saveImageButton: UIBarButtonItem!
    
    // MARK: Privates
    private var originalImage: UIImage?
    private let cachingImageManager: PHCachingImageManager = PHCachingImageManager()
    private let imageFilteringQueue: OperationQueue = OperationQueue()
   
    private lazy var filterCollectionViewController: FilterCollectionViewController? = {
        return self.children.first as? FilterCollectionViewController
    }()
    
    // MARK:- Life Cycle
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }
}

extension PhotoEditViewController {
    
    private func changeImageViewMode() {
        guard let isNavigationBarHidden: Bool = self.navigationController?.isNavigationBarHidden
            else { return }
        
        self.navigationController?.isNavigationBarHidden = !isNavigationBarHidden
        self.view.backgroundColor = isNavigationBarHidden ? UIColor.white : UIColor.black
        self.containerView.isHidden = !self.containerView.isHidden
    }
}

extension PhotoEditViewController {
    private func alertSaveResult(success: Bool, error: Error?) {
        let alertMessage: String
        
        if success {
            alertMessage = "카메라 롤에 저장하였습니다."
        }
        else {
            alertMessage = "사진저장에 실패했습니다. " + (error?.localizedDescription ?? "")
        }
        
        let alert: UIAlertController = UIAlertController(title: "알림", message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil))
        
        OperationQueue.main.addOperation {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension PhotoEditViewController {
    
    // MARK:- IBActions
    @IBAction func tapAssetImage(_ sender: UITapGestureRecognizer) {
        self.changeImageViewMode()
    }
    
    @IBAction func touchUpResetFilterButton(_ sender: UIBarButtonItem) {
        self.assetImageView.image = self.originalImage
        sender.isEnabled = false
        self.saveImageButton.isEnabled = false
    }
    
    @IBAction func touchUpSaveImageButton(_ sender: UIBarButtonItem) {
        
        guard let filteredImage: UIImage = self.assetImageView.image else {
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: filteredImage)
        }, completionHandler: self.alertSaveResult(success:error:))
    }
}

// MARK: - UIScrollViewControllerDelegate
extension PhotoEditViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.assetImageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView,
                                    with view: UIView?) {
        
        if self.navigationController?.isNavigationBarHidden == false {
            self.changeImageViewMode()
        }
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension PhotoEditViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let asset: PHAsset = self.asset else {
            return
        }
        guard let changes = changeInstance.changeDetails(for: asset)
            else { return }
        
        DispatchQueue.main.sync {
            if changes.objectWasDeleted {
                self.navigationController?.popViewController(animated: true)
            } else if let after = changes.objectAfterChanges {
                self.asset = after
            }
        }
    }
}

extension PhotoEditViewController {
    private func adjustFilter(name filterName: String) {
        imageFilteringQueue.addOperation {
            guard let inputImage: UIImage = self.originalImage else { return }
            guard let filter: CIFilter = CIFilter(name: filterName) else { return }
            guard let ciImage: CIImage = CIImage(image: inputImage) else {return }
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            guard let outputImage: CIImage = filter.outputImage else { return }
            let context: CIContext = CIContext(options: nil)
            guard let cgImage: CGImage = context.createCGImage(outputImage,
                                                               from: outputImage.extent)
                else { return }
            let filteredImage: UIImage = UIImage(cgImage: cgImage)
            
            OperationQueue.main.addOperation {
                self.assetImageView.image = filteredImage
                self.resetFilterButton.isEnabled = true
                self.saveImageButton.isEnabled = true
            }
        }
    }
}

extension PhotoEditViewController {
    @objc private func didRecieveUserDidSelectFilterNotification(_ noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        guard let filterName: String = userInfo["filterName"] as? String
            else { return }
        self.adjustFilter(name: filterName)
    }
}

extension PhotoEditViewController {
    
    // MARK:- Methods
    private func setUpImageView() {
        
        guard let asset: PHAsset = self.asset else {
            return
        }
        
        let originalAssetImageSize: CGSize
        originalAssetImageSize = CGSize(width: asset.pixelWidth,
                                        height: asset.pixelHeight)
        
        let manager: PHCachingImageManager = self.cachingImageManager
        manager.requestImage(for: asset,
                             targetSize: originalAssetImageSize,
                             contentMode: PHImageContentMode.aspectFill,
                             options: nil,
                             resultHandler: { image, _ in
                                self.assetImageView.image = image
                                self.originalImage = image
        })
    }
}

extension PhotoEditViewController {
    
    private func setUpNavigationTitle() {
        
        guard let asset: PHAsset = self.asset else {
            return
        }
        
        let dateFormatter: DateFormatter = DateFormatter()
        guard let createdDate: Date = asset.creationDate else {return}
        
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.backgroundColor = UIColor.clear
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textAlignment = NSTextAlignment.center
        dateLabel.numberOfLines = 1
        dateLabel.backgroundColor = UIColor.clear
        dateLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        dateLabel.textColor = UIColor.black
        dateLabel.text = dateFormatter.string(from: createdDate)
        
        dateFormatter.dateFormat = "a hh:mm:ss"
        
        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textAlignment = NSTextAlignment.center
        timeLabel.numberOfLines = 1
        timeLabel.backgroundColor = UIColor.clear
        timeLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        timeLabel.textColor = UIColor.black
        timeLabel.text = dateFormatter.string(from: createdDate)
        
        titleView.addSubview(dateLabel)
        titleView.addSubview(timeLabel)
        
        dateLabel.topAnchor.constraint(equalTo: titleView.topAnchor).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: timeLabel.topAnchor).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: dateLabel.trailingAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
    }
}

extension PhotoEditViewController {
    
    // MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpImageView()
        self.setUpNavigationTitle()
        
        PHPhotoLibrary.shared().register(self)
        
        self.filterCollectionViewController?.photoAsset = asset
        NotificationCenter.default.addObserver(self, selector: #selector(didRecieveUserDidSelectFilterNotification(_:)), name: Notification.Name("UserDidSelectFilterNotification"), object: nil)
    }
}
