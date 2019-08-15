//
//  HHAcountManager.m
//  PhotoSecurity
//
//  Created by vanke on 2019/8/1.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import "HHAcountManager.h"

@implementation HHAcountManager

- (void)setEmail:(NSString *)email {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:email forKey:HHEmailKey];
}


- (NSString *)email {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:HHEmailKey];
}

@end
