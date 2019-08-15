//
//  VKUserInfo.m
//  MeiFang
//
//  Created by Evan on 2017/3/17.
//  Copyright © 2017年 Vanke.com All rights reserved.
//

#import "HHAPPContext.h"


@implementation HHAPPContext

static id _instance;
+ (id)allocWithZone:(struct _NSZone *)zone {
    if (_instance == nil) {
        @synchronized(self) {
            if (_instance == nil) {
                _instance = [super allocWithZone:zone];
            }
        }
    }
    return _instance;
}
+ (instancetype)sharedAppContext {
    if (_instance == nil) {
        @synchronized(self) {
            if (_instance == nil) {
                _instance = [[self alloc] init];
            }
        }
    }
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}



@end

