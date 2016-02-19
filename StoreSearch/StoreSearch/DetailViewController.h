//
//  DetailViewController.h
//  StoreSearch
//
//  Created by mac on 16/2/15.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResult;

typedef NS_ENUM(NSInteger, DetailViewControllerAnimationType) {
    DetailViewControllerAnimationTypeSlide,
    DetailViewControllerAnimationTypeFade
};

@interface DetailViewController : UIViewController
@property (nonatomic, strong) SearchResult *searchResult;

- (void)presentInParentViewController:(UIViewController *)parentViewController;
- (void)dismissFromParentViewController;
- (void)dismissFromParentViewControllerWithAnimationType:(DetailViewControllerAnimationType)animationType;
@end
