//
//  HHPreviewViewController.m
//  PhotoSecurity
//
//  Created by Evan on 2019/8/11.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import "HHPreviewViewController.h"

@interface HHPreviewViewController ()

@property (nonatomic, strong) UIBarButtonItem *deleteButton;
@end

@implementation HHPreviewViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.deleteButton;
    self.view.backgroundColor = [UIColor blackColor];
}

- (UIBarButtonItem *)deleteButton {
    
    if(!_deleteButton){
        
        UIButton *letButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [letButton setImage:[UIImage imageNamed:@"icon_ trash.png"] forState:UIControlStateNormal];
        [letButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -16)];
        [letButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton = [[UIBarButtonItem alloc] initWithCustomView:letButton];
    }
    return _deleteButton;
}

- (void)deleteButtonPressed {
    
    UIAlertController *sheetVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are you sure want to delete this photo", nil)
                                                                     message:NSLocalizedString(@"Data can't recover if be bdeleted", nil) preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                       style:UIAlertActionStyleDestructive
                                                     handler:^(UIAlertAction * _Nonnull action) {
        if(self.deleteImageBlock){
            self.deleteImageBlock(self);
        }
    }];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    [sheetVC addAction:okAction];
    [sheetVC addAction:cancleAction];
    [self presentViewController:sheetVC animated:YES completion:nil];
}

@end
