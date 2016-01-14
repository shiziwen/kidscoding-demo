//
//  ItemDetailViewController.h
//  Checklists-demo
//
//  Created by mac on 15/12/20.
//  Copyright © 2015年 shiziwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ItemDetailViewController;
@class ChecklistItem;

@protocol ItemDetailViewControllerDelegate <NSObject>

- (void)itemDetailViewControllerDidCancel: (ItemDetailViewController *)controller;
- (void)itemDetailViewController: (ItemDetailViewController *)controller didFinishAddingItem:(ChecklistItem *) item;
- (void)itemDetailViewController: (ItemDetailViewController *)controller didFinishEditingItem:(ChecklistItem *) item;

@end

@interface ItemDetailViewController : UITableViewController<UITextFieldDelegate>
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property (weak, nonatomic) IBOutlet UISwitch *switchControl;

@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;


@property(weak, nonatomic) id <ItemDetailViewControllerDelegate> delegate;

@property(strong, nonatomic) ChecklistItem *itemToEdit;
@end
