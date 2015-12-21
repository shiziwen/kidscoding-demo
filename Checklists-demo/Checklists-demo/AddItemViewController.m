//
//  AddItemViewController.m
//  Checklists-demo
//
//  Created by mac on 15/12/20.
//  Copyright © 2015年 shiziwen. All rights reserved.
//

#import "AddItemViewController.h"
#import "ChecklistItem.h"

@interface AddItemViewController ()

@end

@implementation AddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (IBAction)cancel:(id)sender {
    [self.delegate addItemViewControllerDidCancel:self];
}

- (IBAction)done:(id)sender {
    ChecklistItem *item = [[ChecklistItem alloc]init];
    item.text = self.textField.text;
    item.checked = NO;
    
    [self.delegate addItemViewController:self didFinishAddingItem:item];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.textField becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    self.doneBarButton.enabled = ([newText length] > 0);
    
    return YES;
}
@end
