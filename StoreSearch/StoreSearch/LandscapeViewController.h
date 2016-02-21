//
//  LandscapeViewController.h
//  StoreSearch
//
//  Created by mac on 16/2/19.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Search;

@interface LandscapeViewController : UIViewController

//@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) Search *search;

- (void)searchResultsReceived;

@end
