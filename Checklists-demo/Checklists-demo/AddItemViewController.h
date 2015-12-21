//
//  AddItemViewController.h
//  Checklists-demo
//
//  Created by mac on 15/12/20.
//  Copyright © 2015年 shiziwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddItemViewController : UITableViewController<UITextFieldDelegate>
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;

@end
