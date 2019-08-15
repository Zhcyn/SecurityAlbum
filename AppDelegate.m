//
//  AppDelegate.m
//  PhotoSecurity
//
//  Created by huwen on 2017/3/1.
//  Copyright © 2017年 huwen. All rights reserved.
//

#import "AppDelegate.h"
#import "GHPopupEditView.h"
#import "HHSetPasswordViewController.h"
#import "HHNewHomeViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface AppDelegate ()

@property (nonatomic, strong) LAContext *context;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window.backgroundColor = [UIColor whiteColor];
    checkPhotoRootDirectory();
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (0 == [userDefaults stringForKey:XPEncryptionPasswordRandomKey].length) {
        NSString *random = randomString(6);
        [userDefaults setObject:random forKey:XPEncryptionPasswordRandomKey];
        [userDefaults synchronize];
    }

    //
    NSLog(@"Home:%@", NSHomeDirectory());
    
    // 初始化数据库
//    [[HHSQLiteManager sharedSQLiteManager] initializationDatabase];
//    [UMConfigure initWithAppkey:@"5d4d35ef3fc195132b00044c" channel:@"App Store"];
//    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    NSDate *date = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:HHLastUsedDateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    if ([HHPasswordTool isSetPassword]) {
        for (UIView *subview in self.window.subviews) {
            if ([subview isKindOfClass:[GHPopupEditView class]]) {
                [subview removeFromSuperview];
            }
        }
        
        __weak typeof(self) weakSelf = self;
        
        UIViewController *rootVc = [self.window rootViewController];
        if (nil == rootVc.presentedViewController || ![rootVc.presentedViewController isKindOfClass:[HHSetPasswordViewController class]]) {
            [rootVc.presentedViewController dismissViewControllerAnimated:NO completion:nil];
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            HHSetPasswordViewController *unlockVc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HHSetPasswordViewController"];
            [unlockVc showTips];
            [rootVc presentViewController:unlockVc animated:NO completion:^{
                if(touchIDTypeEnabled()){
                    //如果设置了FaceID
                    self.context = [[LAContext alloc] init];
                    [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                     localizedReason:NSLocalizedString(@"You can use the Touch ID to verify the fingerprint quickly to complete the unlock application", nil)
                                               reply:^(BOOL success, NSError * _Nullable error) {
                                                   
                                                   if (!success) {
                                                       return;
                                                   }else{
                                                       [unlockVc dismissViewControllerAnimated:YES completion:nil];
                                                   }
                                               }];
                }
               
            }];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSDate *date = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:HHLastUsedDateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
