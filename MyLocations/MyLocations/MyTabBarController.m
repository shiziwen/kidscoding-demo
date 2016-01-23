//
//  MyTabBarController.m
//  MyLocations
//
//  Created by mac on 16/1/24.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import "MyTabBarController.h"

@interface MyTabBarController ()

@end

@implementation MyTabBarController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return nil;
}
@end
