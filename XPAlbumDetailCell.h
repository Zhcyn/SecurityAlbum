//
//  XPAlbumDetailCell.h
//  PhotoSecurity
//
//  Created by nhope on 2017/3/16.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HHAlbumModel;
@class HHPhotoModel;

@interface XPAlbumDetailCell : UICollectionViewCell

- (void)showImageWithAlbum:(HHAlbumModel *)album photo:(HHPhotoModel *)photo;
- (void)changeSelectState:(BOOL)select;

@end
