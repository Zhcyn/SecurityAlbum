//
//  HHAlbumDetailViewController.h
//  PhotoSecurity
//
//  Created by nhope on 2017/3/8.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TZImagePickerController.h>
@class HHAlbumModel;

typedef void(^HHChangeAblumThumbBlock)(HHAlbumModel *ablum);

@interface HHAlbumDetailViewController : UICollectionViewController<TZImagePickerControllerDelegate>

@property (nonatomic, strong) HHAlbumModel *album;
@property (nonatomic, assign) BOOL isChoseThumb; //是否选择封面
@property (nonatomic, copy) HHChangeAblumThumbBlock changeAlbumBlock;

@end
