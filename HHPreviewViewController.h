//
//  HHPreviewViewController.h
//  PhotoSecurity
//
//  Created by Evan on 2019/8/11.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import <QuickLook/QuickLook.h>

NS_ASSUME_NONNULL_BEGIN
@class HHPreviewViewController;
typedef void(^HHDeleteImageBlock)(HHPreviewViewController *);
@interface HHPreviewViewController : QLPreviewController

@property (nonatomic, copy) HHDeleteImageBlock deleteImageBlock;
@end

NS_ASSUME_NONNULL_END
