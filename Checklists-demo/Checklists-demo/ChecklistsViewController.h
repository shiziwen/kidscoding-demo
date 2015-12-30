//
//  ViewController.h
//  Checklists-demo
//
//  Created by mac on 15/12/18.
//  Copyright © 2015年 shiziwen. All rights reserved.
//

#import <UIKit/UIKit.h> 
#import "ItemDetailViewController.h"

@class Checklist;

@interface ChecklistsViewController : UITableViewController<ItemDetailViewControllerDelegate>
@property (nonatomic, strong) Checklist *checklist;

@end

