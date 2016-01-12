//
//  AllListsViewController.h
//  Checklists-demo
//
//  Created by mac on 15/12/28.
//  Copyright © 2015年 shiziwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListDetailViewController.h"

@class DataModel;

@interface AllListsViewController : UITableViewController<ListDetailViewControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) DataModel *dataModel;

@end
