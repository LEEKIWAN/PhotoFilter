//
//  Album.swift
//  PhotoFilter
//
//  Created by 이기완 on 22/03/2019.
//  Copyright © 2019 이기완. All rights reserved.
//

import UIKit
import Photos


class AlbumObject: NSObject {
    var imageTotalCount: String?
    var coverImage: UIImage?
    var title: String?
    var fetchResult: PHFetchResult<PHAsset>?
}
