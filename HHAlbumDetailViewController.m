//
//  HHAlbumDetailViewController.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/8.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "HHAlbumDetailViewController.h"
#import "HHPhotoPickerViewController.h"
#import "HHPreviewViewController.h"
#import "XPNavigationController.h"
#import "XPAlbumDetailCell.h"
#import "HHAlbumModel.h"
#import "HHPhotoModel.h"
#import <Photos/Photos.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <AVFoundation/AVFoundation.h>
#import <QuickLook/QuickLook.h>
#import <MobileCoreServices/MobileCoreServices.h>
//#import <GoogleMobileAds/GoogleMobileAds.h>
#import "NSDate+Category.h"

#define OPERATION_TOOLBAR_TAG                   999
#define OPERATION_TOOLBAR_HEIGHT                64.0
#define OPERATION_TOOLBAR_INDICATOR_ITEM_TAG    123


@interface HHAlbumDetailViewController ()
<DZNEmptyDataSetSource,
DZNEmptyDataSetDelegate,
XPPhotoPickerViewControllerDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
QLPreviewControllerDataSource,
QLPreviewControllerDelegate>

/// 该相册下的图片数据
@property (nonatomic, strong) NSMutableArray<HHPhotoModel *> *photos;
/// 是否处于编辑模式
@property (nonatomic, assign) BOOL editing;
/// 选中列表(key为下标索引,value固定为@(YES))
@property (nonatomic, strong) NSMutableDictionary *selectMaps;

@property (nonatomic, strong) UIBarButtonItem *editButton;
@property (nonatomic, strong) UIBarButtonItem *addButton;

@end

@implementation HHAlbumDetailViewController

static CGFloat const kCellBorderMargin = 1.0;

#pragma mark - Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = self.isChoseThumb ? @"Select the cover" : self.album.name;
    
    
    self.collectionView.emptyDataSetSource = self;
    self.collectionView.emptyDataSetDelegate = self;
    self.collectionView.frame = CGRectMake(0, 1, APP_WIDH, APP_HIGH-1);
    
//    // 加载相册所有图片数据
//    [self configAlbumData];
    
    if(!self.isChoseThumb){
        self.navigationItem.rightBarButtonItems = @[self.editButton, self.addButton];
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 加载相册所有图片数据
    [self configAlbumData];
}

- (void)configAlbumData {
    HHSQLiteManager *manager = [HHSQLiteManager sharedSQLiteManager];
    self.photos = [manager requestAllPhotosWithAlbumid:self.album.albumid];
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
//    NSDate *after3Hours = [NSDate dateWithHoursFromNow:2];
//    NSDate *lastUseDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:HHLastUsedDateKey];
//    if(lastUseDate){
//        //上一次时间 + 3小时
//        NSDate *date = [lastUseDate dateByAddingHours:2];
//        if([after3Hours isLaterThanDate:date]){
//            //每两个小时展示一个插入广告
//            [self showTheInterstitialAd];
//        }
//    }
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * const identifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor randomColor];
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    HHPhotoModel *photo = self.photos[indexPath.row];
    NSString *key = [NSString stringWithFormat:@"%ld", indexPath.row];
    BOOL isSelect = _editing && ([_selectMaps objectForKey:key] ? YES : NO);
    XPAlbumDetailCell *photoCell = (XPAlbumDetailCell *)cell;
    [photoCell showImageWithAlbum:self.album photo:photo];
    [photoCell changeSelectState:isSelect];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if(self.isChoseThumb){
        
        HHPhotoModel *photo = self.photos[indexPath.row];
        self.album.thumbImage = photo;
        
        if(self.changeAlbumBlock){
            self.changeAlbumBlock(self.album ? self.album : [HHAlbumModel new]);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        if (_editing) {
            NSString *key = [NSString stringWithFormat:@"%ld", indexPath.row];
            if (nil == _selectMaps) _selectMaps = [NSMutableDictionary dictionary];
            BOOL isExists = [_selectMaps objectForKey:key] ? YES : NO;
            XPAlbumDetailCell *cell = (XPAlbumDetailCell *)[collectionView cellForItemAtIndexPath:indexPath];
            if (isExists) {
                [_selectMaps removeObjectForKey:key];
                [cell changeSelectState:NO];
            } else {
                if (9 <= _selectMaps.count) {
                    [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"You can only select up to 9 images.", nil)];
                    return;
                }
                [_selectMaps setObject:@(YES) forKey:key];
                [cell changeSelectState:YES];
            }
            [self updateToolbarIndicator];
        } else {

            HHPreviewViewController *previewController = [[HHPreviewViewController alloc] init];
            previewController.delegate = self;
            previewController.dataSource = self;
            previewController.currentPreviewItemIndex = indexPath.row;
            previewController.deleteImageBlock = ^(HHPreviewViewController * _Nonnull previewVC) {
                //防止删除相册时候数组越界
                NSInteger index = indexPath.row;
                if(index >= self.photos.count){
                    index = self.photos.count - 1;
                }
                if(index < 0){
                    index = 0;
                }
                HHPhotoModel *photo = self.photos[index];
                HHSQLiteManager *manager = [HHSQLiteManager sharedSQLiteManager];
                BOOL success = [manager deletePhotos:@[photo] fromAlbum:self.album];
                if(success) {
                    [self.photos removeObject:photo];
                    if(!self.photos.count){
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    [previewVC reloadData];
                    [self.collectionView reloadData];
                };
            };
            [self.navigationController pushViewController:previewController animated:YES];
        }
    }
    
    
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = CGRectGetWidth(collectionView.frame);
    int maxItemCount = ceil(width/XPThumbImageWidthAndHeightKey);
    CGFloat wh = (width-(maxItemCount-1)*kCellBorderMargin)/maxItemCount;
    return CGSizeMake(wh, wh);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kCellBorderMargin;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kCellBorderMargin;
}

#pragma mark - <QLPreviewControllerDataSource>

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return self.photos.count;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    HHPhotoModel *photo = self.photos[index];
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", photoRootDirectory(),self.album.directory,photo.filename];
    NSURL *url = [NSURL fileURLWithPath:path];
    return url;
}


#pragma mark - <UIImagePickerControllerDelegate>
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSData *data = nil;
    NSString *filename = nil;
    UIImage *previewImage = nil;
    XPFileType filetype = XPFileTypeImage;
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    CGSize size = CGSizeMake(XPThumbImageWidthAndHeightKey, XPThumbImageWidthAndHeightKey);
    if ([mediaType isEqualToString:(NSString*)kUTTypeMovie]) { // 视频
        NSURL *mediaURL = info[UIImagePickerControllerMediaURL];
        data = [NSData dataWithContentsOfURL:mediaURL];
        filename = [NSString stringWithFormat:@"%@.%@", generateUniquelyIdentifier(),mediaURL.pathExtension];
        previewImage = [UIImage snapshotImageWithVideoURL:mediaURL];
        previewImage = [UIImage thumbnailImageFromSourceImage:previewImage destinationSize:size];
        filetype = XPFileTypeVideo;
    } else { // 拍照
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        data = UIImageJPEGRepresentation(image, 0.75);
        filename = [NSString stringWithFormat:@"%@.JPG", generateUniquelyIdentifier()];
        previewImage = [UIImage thumbnailImageFromSourceImageData:data destinationSize:size];
    }
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", photoRootDirectory(),self.album.directory,filename];
    BOOL isSuccess = [data writeToFile:path atomically:YES];
    if (isSuccess) {
        NSString *thumbPath = [NSString stringWithFormat:@"%@/%@/%@/%@", photoRootDirectory(),self.album.directory,XPThumbDirectoryNameKey,filename];
        NSData *thumbData = UIImageJPEGRepresentation(previewImage, 0.75);
        [thumbData writeToFile:thumbPath atomically:YES];

        // 保存图片记录到数据库
        HHPhotoModel *photo = [[HHPhotoModel alloc] init];
        photo.albumid = self.album.albumid;
        photo.filename = filename;
        photo.originalname = @"";
        photo.createtime = photo.addtime = [[NSDate date] timeIntervalSince1970];
        photo.filesize = data.length;
        photo.filetype = filetype;
        [[HHSQLiteManager sharedSQLiteManager] addPhotos:@[photo]];
        self.album.count++;

        // 加载最新添加的图片信息并显示在最后
        NSArray *latestPhotos = [[HHSQLiteManager sharedSQLiteManager] requestLatestPhotosWithAlbumid:self.album.albumid count:1];
        if (nil == self.photos) {
            self.photos = [NSMutableArray array];
        }
        [self.photos addObjectsFromArray:latestPhotos];
        [self.collectionView reloadData];
    } else {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Photo saved failed", nil)];
    }
}

#pragma mark - <DZNEmptyDataSetSource>

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = NSLocalizedString(@"Album is empty", nil);
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]
                                 };
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = NSLocalizedString(@"Please click the button below to add a picture.", nil);
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph
                                 };
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    NSString *text = NSLocalizedString(@"Add pictures", nil);
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                 NSForegroundColorAttributeName:  [UIColor colorWithHex:(state==UIControlStateHighlighted?@"0xC6DEF9":@"0x007AFF")]
                                 };
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"empty-box"];
}

#pragma mark - <DZNEmptyDataSetDelegate>

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self addButtonPressed:nil];
}

#pragma mark - Actions

/**
 添加相片
 */
- (void)addButtonPressed:(UIButton *)sender {
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Photo Library", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { // 照片图库
    
        
        TZImagePickerController *imagePickerVC = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:weakSelf];
        [self presentViewController:imagePickerVC animated:YES completion:nil];
        
    }]];
    
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo or Video", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { // 拍照

        if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            // 没有摄像头
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"The camera is not available", nil)];
            return;
        }
        
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
            
            //没有授权使用摄像头
            NSString *title = NSLocalizedString(@"Not authorized to use the camera", nil);
            NSString *message = NSLocalizedString(@"Please open in iPhone \"Settings - Privacy - Camera\"", nil);
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
            [weakSelf presentViewController:alertController animated:YES completion:nil];
            return;
        }
        
        UIImagePickerController *pickerVc = [[UIImagePickerController alloc] init];
        pickerVc.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerVc.mediaTypes = @[(NSString*)kUTTypeImage, (NSString*)kUTTypeMovie];
        pickerVc.delegate = weakSelf;
        [self presentViewController:pickerVc animated:weakSelf completion:nil];
        
    }]];
    
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    if (iPad()) {
        UIPopoverPresentationController *popover = [alert popoverPresentationController];
        if ([sender isKindOfClass:[UIBarButtonItem class]]) {
            popover.barButtonItem = sender;
        } else {
            popover.sourceView = sender;
            popover.sourceRect = [(UIView *)sender bounds];
        }
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    [weakSelf presentViewController:alert animated:YES completion:nil];
}

- (void)editButtonPressed:(UIButton *)sender {
    
    self.editing = !self.editing;
    if (self.editing) {
        
        [sender setImage:[UIImage imageNamed:@"icon-done"] forState:UIControlStateNormal];

        self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 0.0, OPERATION_TOOLBAR_HEIGHT, 0.0);
        CGFloat contentHeight = self.collectionView.contentSize.height;
        CGFloat offsetY = self.collectionView.contentOffset.y;
        CGFloat visibleHeight = CGRectGetHeight(self.collectionView.frame);
        BOOL isEndBottom = contentHeight>=visibleHeight && offsetY+visibleHeight >= contentHeight;
        if (isEndBottom) {
            // 滚动视图已滑动到底部,当显示Toolbar时将滚动视图网上偏移,以免Toolbar遮挡图片
            CGPoint offset = self.collectionView.contentOffset;
            offset.y += OPERATION_TOOLBAR_HEIGHT;
            [UIView animateWithDuration:0.5 animations:^{
                self.collectionView.contentOffset = offset;
            }];
        }
        [self addOperationToolbar];
    } else {
        [sender setImage:[UIImage imageNamed:@"icon-edit"] forState:UIControlStateNormal];
        self.collectionView.contentInset = UIEdgeInsetsZero;
        [[self.view viewWithTag:OPERATION_TOOLBAR_TAG] removeFromSuperview];
        if (_selectMaps.count) { // 取消图片的选中状态
            NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
            for (NSString *key in _selectMaps) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:key.integerValue inSection:0];
                [indexPaths addObject:indexPath];
            }
            [self.collectionView reloadItemsAtIndexPaths:indexPaths];
        }
        [_selectMaps removeAllObjects];
    }
}

/// 保存选中的图片
- (void)saveButtonItemAction:(UIBarButtonItem *)sender {
    if (0 == _selectMaps.count) {

        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Please select the pictures you want to save", nil)];
        return;
    }
    @weakify(self);
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if (status != PHAuthorizationStatusAuthorized) {
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"No authorization to access Photo Library", nil)];
                return;
            }
            
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Copying the pictures...", nil)];
            // 保存图片到系统相册(可以保存到自定义相册)
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                for (NSString *key in self.selectMaps) {
                    NSInteger index = [key integerValue];
                    HHPhotoModel *photo = self.photos[index];
                    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", photoRootDirectory(),self.album.directory,photo.filename];
                    NSURL *fileURL = [NSURL fileURLWithPath:path];
                    [PHAssetCreationRequest creationRequestForAssetFromImageAtFileURL:fileURL];
                }
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{

                    [SVProgressHUD dismiss];
                    if (error) {
                        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Photo saved failed", nil)];
                    } else {
                        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Photo saved successfully", nil)];
                    }
                });
            }];
        });
    }];
}

/// 删除选中的图片
- (void)deleteButtonItemAction:(UIBarButtonItem *)sender {
    if (0 == _selectMaps.count) {

        [SVProgressHUD showWithStatus:NSLocalizedString(@"Please select the pictures you want to delete", nil)];
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are you sure you want to delete the selected photos?", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    @weakify(self);
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Deleting pictures...", nil)];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @strongify(self);
            NSMutableArray<HHPhotoModel *> *photos = [NSMutableArray array];
            for (NSString *key in self.selectMaps) {
                NSInteger index = [key integerValue];
                HHPhotoModel *photo = self.photos[index];
                [photos addObject:photo];
            }
            HHSQLiteManager *manager = [HHSQLiteManager sharedSQLiteManager];
            BOOL success = [manager deletePhotos:photos fromAlbum:self.album];
            
            if(success) {
                [self.photos removeObjectsInArray:photos];
                self.album.count = MAX(0, self.album.count-photos.count);
            }
            
            [self.selectMaps removeAllObjects];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
                
                [SVProgressHUD dismiss];
                [self.selectMaps removeAllObjects];
                [self updateToolbarIndicator];
                
            });
        });
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TZImagePickerControllerDelegate

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
     NSLog(@"cancel");
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos
                 sourceAssets:(NSArray *)assets
        isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
                        infos:(NSArray<NSDictionary *> *)infos {
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Copying the pictures...", nil)];
    @weakify(self);
    __block NSMutableArray<HHPhotoModel *> *imagePhotos = [NSMutableArray array];
    
    //从系统中拷贝图片/视频到沙盒目录
    for(PHAsset *asset in assets) {
        if (asset.mediaType == PHAssetMediaTypeUnknown || asset.mediaType == PHAssetMediaTypeAudio) continue;
            @strongify(self);
            if (asset.mediaType == PHAssetMediaTypeImage) {
                
                //图片
                [self fetchImageForPHAsset:asset completionHandler:^(HHPhotoModel *photo) {
                    [imagePhotos addObject:photo];
                    
                    
                    if(imagePhotos.count == assets.count){
                       
                        [SVProgressHUD dismiss];

                        [[HHSQLiteManager sharedSQLiteManager] addPhotos:imagePhotos];

                        //将图片数据写入数据库
                        self.album.count += photos.count;
                        
                        //获取允许删除的图片资源
                        NSMutableArray<PHAsset *> *deleteAssets = [NSMutableArray array];
                        for (PHAsset *asset in assets) {
                            if ([asset canPerformEditOperation:PHAssetEditOperationDelete]) {
                                [deleteAssets addObject:asset];
                            }
                        }
                        
                        if(deleteAssets.count) {
                            //提示用户是否删除系统图片
                            UIAlertController *alert = [UIAlertController
                                                        alertControllerWithTitle:NSLocalizedString(@"Whether to delete the selected image from the photo library?", nil)
                                                        message:nil
                                                        preferredStyle:UIAlertControllerStyleAlert];
                            
                            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                                
                                //展示广告
        
                                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                                    
                                    [PHAssetChangeRequest deleteAssets:deleteAssets];
                                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                                    
                                    NSString *message = NSLocalizedString(@"Delete fail.", nil);
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [SVProgressHUD showInfoWithStatus:message];
                                    });

                                }];
                            }]];
                            
                            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            }]];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                        
                        // 加载最新添加的图片信息并显示在最后
                        NSArray *latestPhotos = [[HHSQLiteManager sharedSQLiteManager] requestLatestPhotosWithAlbumid:self.album.albumid count:imagePhotos.count];
                        if (nil == self.photos) {
                            self.photos = [NSMutableArray array];
                        }
                        [self.photos addObjectsFromArray:latestPhotos];
                        [self.collectionView reloadData];
                    }
                }];
            }
    }
}

//- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos
//                 sourceAssets:(NSArray *)assets
//        isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
//                        infos:(NSArray<NSDictionary *> *)infos {
//
//        @weakify(self);
//        dispatch_group_t group = dispatch_group_create();
//        dispatch_queue_t queue = dispatch_queue_create("com.0daybug.globalqueue", DISPATCH_QUEUE_CONCURRENT);
//        __block NSMutableArray<HHPhotoModel *> *imagePhotos = [NSMutableArray array];
//        // 从系统中拷贝图片/视频到沙盒目录
//
//        for (PHAsset *asset in assets) {
//            if (asset.mediaType == PHAssetMediaTypeUnknown || asset.mediaType == PHAssetMediaTypeAudio) continue;
//            dispatch_group_enter(group);
//            dispatch_group_async(group, queue, ^{
//                @strongify(self);
//                if (asset.mediaType == PHAssetMediaTypeImage) {
//                    //图片
//                    [self fetchImageForPHAsset:asset completionHandler:^(HHPhotoModel *photo) {
//                        [imagePhotos addObject:photo];
//                        dispatch_group_leave(group);
//                    }];
//                }
//            });
//        }
//
//        // 所有图片/视频已拷贝完毕
//        dispatch_group_notify(group, queue, ^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//                @strongify(self);
//                [[HHSQLiteManager sharedSQLiteManager] addPhotos:imagePhotos];
//
//                //将图片数据写入数据库
//                self.album.count += photos.count;
//
//                //获取允许删除的图片资源
//                NSMutableArray<PHAsset *> *deleteAssets = [NSMutableArray array];
//                for (PHAsset *asset in assets) {
//                    if ([asset canPerformEditOperation:PHAssetEditOperationDelete]) {
//                        [deleteAssets addObject:asset];
//                    }
//                }
//
//                if(deleteAssets.count) {
//                    // 提示用户是否删除系统图片
//                    UIAlertController *alert = [UIAlertController
//                                                alertControllerWithTitle:NSLocalizedString(@"Whether to delete the selected image from the photo library?", nil)
//                                                message:nil
//                                                preferredStyle:UIAlertControllerStyleAlert];
//
//                    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//
//                        //展示广告
//                        [self showTheInterstitialAd];
//                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//
//                            [PHAssetChangeRequest deleteAssets:deleteAssets];
//                        } completionHandler:^(BOOL success, NSError * _Nullable error) {
//                            if(success == NO) {
//                                NSString *message = NSLocalizedString(@"Delete fail.", nil);
//                            }
//                        }];
//                    }]];
//
//                    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                        //展示广告
//                        [self showTheInterstitialAd];
//                    }]];
//                    [self presentViewController:alert animated:YES completion:nil];
//                }
//
//                // 加载最新添加的图片信息并显示在最后
//                NSArray *latestPhotos = [[HHSQLiteManager sharedSQLiteManager] requestLatestPhotosWithAlbumid:self.album.albumid count:imagePhotos.count];
//                if (nil == self.photos) {
//                    self.photos = [NSMutableArray array];
//                }
//                [self.photos addObjectsFromArray:latestPhotos];
//                [self.collectionView reloadData];
//            });
//        });
//
//}


//- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset {
//
//    NSLog(@"imagePickerController:%s %@", __func__, [NSThread currentThread]);
//
//    [SVProgressHUD showWithStatus:NSLocalizedString(@"Copying the pictures...", nil)];
//
//    dispatch_group_t group = dispatch_group_create();
//    dispatch_queue_t queue = dispatch_queue_create("com.0daybug.globalqueue", DISPATCH_QUEUE_CONCURRENT);
//
//    __block NSMutableArray<HHPhotoModel *> *imagePhotos = [NSMutableArray array];
//
//    // 从系统中拷贝图片/视频到沙盒目录
//    dispatch_group_enter(group);
//        dispatch_group_async(group, queue, ^{
//
//            if (asset.mediaType == PHAssetMediaTypeVideo) { // 视频
//                [self fetchVideoForPHAsset:asset completionHandler:^(HHPhotoModel *photo) {
//                    [imagePhotos addObject:photo];
//                    dispatch_group_leave(group);
//                }];
//            }
//    });
//
//    // 所有图片/视频已拷贝完毕
//    dispatch_group_notify(group, queue, ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//
//            [[HHSQLiteManager sharedSQLiteManager] addPhotos:imagePhotos]; // 将图片数据写入数据库
//            self.album.count += 1;
//            [SVProgressHUD dismiss];
//            // 获取允许删除的图片资源
//            NSMutableArray<PHAsset *> *deleteAssets = [NSMutableArray array];
//            if ([asset canPerformEditOperation:PHAssetEditOperationDelete]) {
//                [deleteAssets addObject:asset];
//            }
//
//            if (deleteAssets.count) {
//                // 提示用户是否删除系统图片
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Whether to delete the selected image from the photo library?", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
//                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//
//                        [PHAssetChangeRequest deleteAssets:deleteAssets];
//                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
//                        if (success == NO) {
//                            NSString *message = NSLocalizedString(@"Delete fail.", nil);
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                [SVProgressHUD showInfoWithStatus:message];
//                            });
//                        }
//                    }];
//                }]];
//
//                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
//                [self presentViewController:alert animated:YES completion:nil];
//            }
//            // 加载最新添加的图片信息并显示在最后
//            NSArray *latestPhotos = [[HHSQLiteManager sharedSQLiteManager] requestLatestPhotosWithAlbumid:self.album.albumid count:imagePhotos.count];
//            if (nil == self.photos) {
//                self.photos = [NSMutableArray array];
//            }
//            [self.photos addObjectsFromArray:latestPhotos];
//            [self.collectionView reloadData];
//        });
//    });
//
//}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset {
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Copying the pictures...", nil)];
    
    __block NSMutableArray<HHPhotoModel *> *imagePhotos = [NSMutableArray array];
    
        [self fetchVideoForPHAsset:asset completionHandler:^(HHPhotoModel *photo) {
            
            [imagePhotos addObject:photo];
           
            //将图片数据写入数据库
            [[HHSQLiteManager sharedSQLiteManager] addPhotos:imagePhotos];
            self.album.count += 1;
            
            [SVProgressHUD dismiss];
            //获取允许删除的图片资源
            NSMutableArray<PHAsset *> *deleteAssets = [NSMutableArray array];
            if ([asset canPerformEditOperation:PHAssetEditOperationDelete]) {
                [deleteAssets addObject:asset];
            }
            
            if(deleteAssets.count){
                
                // 提示用户是否删除系统图片
                UIAlertController *alert =
                [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Whether to delete the selected image from the photo library?", nil) message:nil
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                [alert addAction:[UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Delete", nil)
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction * _Nonnull action) {
                                      
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        
                        [PHAssetChangeRequest deleteAssets:deleteAssets];
                        
                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                        
                        if (success == NO) {
                            NSString *message = NSLocalizedString(@"Delete fail.", nil);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SVProgressHUD showInfoWithStatus:message];
                            });
                        }
                    }];
                }]];
                
                [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
            
            //加载最新添加的图片信息并显示在最后
            NSArray *latestPhotos = [[HHSQLiteManager sharedSQLiteManager] requestLatestPhotosWithAlbumid:self.album.albumid count:imagePhotos.count];
            if (nil == self.photos) {
                self.photos = [NSMutableArray array];
            }
            [self.photos addObjectsFromArray:latestPhotos];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
            
        }];

}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(PHAsset *)asset {
    
}

// 决定相册显示与否
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(PHFetchResult *)result {
    return YES;
}

#pragma mark - Private

/// 从系统中获取视频文件
- (void)fetchVideoForPHAsset:(PHAsset *)asset completionHandler:(void(^)(HHPhotoModel *photo))completionHandler {
   
    @weakify(self);
    PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;

    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        @strongify(self);
        if (![asset isKindOfClass:[AVURLAsset class]]) return;
        AVURLAsset *urlAsset = (AVURLAsset *)asset;
        // 视频文件
        NSString *suffix = [urlAsset.URL.absoluteString pathExtension];
        NSString *filename = [NSString stringWithFormat:@"%@.%@", generateUniquelyIdentifier(),suffix];
        NSData *videoData = [NSData dataWithContentsOfURL:urlAsset.URL];
        NSString *path = [NSString stringWithFormat:@"%@/%@/%@", photoRootDirectory(),self.album.directory,filename];
        [videoData writeToFile:path atomically:YES];
        // 视频预览图
        UIImage *thumbImage = [UIImage snapshotImageWithVideoURL:urlAsset.URL];
        thumbImage = [UIImage thumbnailImageFromSourceImage:thumbImage destinationSize:CGSizeMake(XPThumbImageWidthAndHeightKey, XPThumbImageWidthAndHeightKey)];
        NSString *thumbPath = [NSString stringWithFormat:@"%@/%@/%@/%@", photoRootDirectory(),self.album.directory,XPThumbDirectoryNameKey,filename];

        NSString *pressRate =  [[NSUserDefaults standardUserDefaults] valueForKey:@"KPressRateKey"];
        CGFloat rate = [pressRate floatValue] == 0 ? 1 : [pressRate floatValue];
        NSData *thumbData = UIImageJPEGRepresentation(thumbImage, rate);
        
        [thumbData writeToFile:thumbPath atomically:YES];
        // 保存视频信息
        HHPhotoModel *photo = [[HHPhotoModel alloc] init];
        photo.albumid = self.album.albumid;
        photo.filename = filename;
        photo.originalname = [urlAsset.URL.absoluteString lastPathComponent];
        photo.addtime = [[NSDate date] timeIntervalSince1970];
        photo.filesize = videoData.length;
        photo.filetype = XPFileTypeVideo;
        
        if (nil != completionHandler) {
            completionHandler(photo);
        }
    }];
}

/// 从系统中获取图片文件
- (void)fetchImageForPHAsset:(PHAsset *)asset completionHandler:(void(^)(HHPhotoModel *photo))completionHandler {
   
    @weakify(self);
    PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionOriginal;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        @strongify(self);
        NSURL *imageFileURL = info[@"PHImageFileURLKey"];
        HHPhotoModel *photo = [[HHPhotoModel alloc] init];
        photo.albumid = self.album.albumid;
        photo.filename = [NSString stringWithFormat:@"%@.%@",generateUniquelyIdentifier(),imageFileURL.pathExtension];
        photo.originalname = [imageFileURL lastPathComponent];
        photo.createtime = [asset.creationDate timeIntervalSince1970];
        photo.addtime = [[NSDate date] timeIntervalSince1970];
        photo.filesize = imageData.length;
        photo.filetype = [imageFileURL.pathExtension.uppercaseString isEqualToString:@"GIF"] ? XPFileTypeGIFImage : XPFileTypeImage;
        
        // 将图片写入目标文件
        NSString *path = [NSString stringWithFormat:@"%@/%@/%@", photoRootDirectory(),self.album.directory,photo.filename];
        [imageData writeToFile:path atomically:YES];
        
        // 生成缩略图并保存
        NSString *thumbPath = [NSString stringWithFormat:@"%@/%@/%@/%@", photoRootDirectory(),self.album.directory,XPThumbDirectoryNameKey,photo.filename];
        UIImage *thumbImage = nil;
        CGSize thumbImageSize = CGSizeMake(XPThumbImageWidthAndHeightKey, XPThumbImageWidthAndHeightKey);
        if (photo.filetype == XPFileTypeGIFImage) {
            UIImage *tmpImage = [UIImage snapshotImageWithGIFImageURL:imageFileURL];
            thumbImage = [UIImage thumbnailImageFromSourceImage:tmpImage destinationSize:thumbImageSize];
        } else {
            thumbImage = [UIImage thumbnailImageFromSourceImageData:imageData destinationSize:thumbImageSize];
        }
        
        NSString *pressRate =  [[NSUserDefaults standardUserDefaults] valueForKey:@"KPressRateKey"];
        CGFloat rate = [pressRate floatValue] == 0 ? 1 : [pressRate floatValue];
            NSData *thumbData = UIImageJPEGRepresentation(thumbImage, rate);
        [thumbData writeToFile:thumbPath atomically:YES];
        
        if (nil != completionHandler) {
            completionHandler(photo);
        }
    }];
}

/// 添加底部的操作条
- (void)addOperationToolbar {
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.tag = OPERATION_TOOLBAR_TAG;
    [self.view addSubview:toolbar];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(toolbar)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolbar(==height)]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:@{@"height":@(OPERATION_TOOLBAR_HEIGHT)} views:NSDictionaryOfVariableBindings(toolbar)]];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(saveButtonItemAction:)];
    UIBarButtonItem *spaceItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spaceItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteButtonItemAction:)];
    UIImage *image = [[UIImage roundSubscriptImageWithImageSize:CGSizeMake(30.0, 30.0) backgoundColor:[UIColor colorWithHex:@"0xC2E4C4"] subscript:0 fontSize:16.0 textColor:[UIColor whiteColor]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *numberItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:nil action:nil];
    numberItem.tag = OPERATION_TOOLBAR_INDICATOR_ITEM_TAG;
    numberItem.enabled = NO;
    toolbar.items = @[saveItem, spaceItem1, numberItem, spaceItem2, deleteItem];
}

/// 更新toolbar上的数字
- (void)updateToolbarIndicator {
    NSUInteger count = _selectMaps.count;
    UIColor *backgroundColor = [UIColor colorWithHex:(count==0 ? @"0xC2E4C4" : @"0x38BD20")];
    UIImage *image = [[UIImage roundSubscriptImageWithImageSize:CGSizeMake(30.0, 30.0) backgoundColor:backgroundColor subscript:count fontSize:16.0 textColor:[UIColor whiteColor]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIToolbar *toolbar = [self.view viewWithTag:OPERATION_TOOLBAR_TAG];
    for (UIBarButtonItem *item in toolbar.items) {
        if (item.tag == OPERATION_TOOLBAR_INDICATOR_ITEM_TAG) {
            item.image = image;
            break;
        }
    }
}

#pragma mark - Getter
- (UIBarButtonItem *)editButton {
    
    if(!_editButton){
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 44)];
        [button setImage:[UIImage imageNamed:@"icon-edit"] forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -5);
        [button addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _editButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    
    return _editButton;
}

- (UIBarButtonItem *)addButton {
    
    if(!_addButton){
        UIButton *letButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [letButton setImage:[UIImage imageNamed:@"icon-add.png"] forState:UIControlStateNormal];
        letButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [letButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _addButton = [[UIBarButtonItem alloc] initWithCustomView:letButton];
    }
    return _addButton;
}
@end
