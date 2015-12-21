//
//  AddItemViewController.h
//  Checklists-demo
//
//  Created by mac on 15/12/20.
//  Copyright © 2015年 shiziwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddItemViewController;
@class ChecklistItem;

@protocol AddItemViewControllerDelegate <NSObject>

- (void)addItemViewControllerDidCancel: (AddItemViewController *)controller;
- (void)addItemViewController: (AddItemViewController *)controller didFinishAddingItem:(ChecklistItem *) item;
- (void)addItemVIewcontroller: (AddItemViewController *)controller didFinishEditingItem:(ChecklistItem *) item;

@end

@interface AddItemViewController : UITableViewController<UITextFieldDelegate>
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;

@property(weak, nonatomic) id <AddItemViewControllerDelegate> delegate;

@property(strong, nonatomic) ChecklistItem *itemToEdit;
@end
