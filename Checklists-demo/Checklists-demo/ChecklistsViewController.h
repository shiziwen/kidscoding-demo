//
//  ViewController.h
//  Checklists-demo
//
//  Created by mac on 15/12/18.
//  Copyright © 2015年 shiziwen. All rights reserved.
//

#import <UIKit/UIKit.h> 
#import "AddItemViewController.h"
#import "ChecklistItem.h"

@interface ChecklistsViewController : UITableViewController<AddItemViewControllerDelegate>

- (IBAction)addItem:(id)sender;

@end

