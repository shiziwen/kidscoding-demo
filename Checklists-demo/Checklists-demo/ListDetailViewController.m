//
//  ListDetailViewController.m
//  Checklists-demo
//
//  Created by mac on 15/12/29.
//  Copyright © 2015年 shiziwen. All rights reserved.
//

#import "ListDetailViewController.h"
#import "Checklist.h"

@implementation ListDetailViewController {
    NSString *_iconName;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        _iconName = @"Folder";
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.checklistToEdit != nil) {
        self.title = @"Edit Checklist";
        self.textField.text = self.checklistToEdit.name;
        self.doneBarButton.enabled = YES;
        _iconName = self.checklistToEdit.iconName;
    }
    NSLog(@"icon is %@", _iconName);
    self.iconImageView.image = [UIImage imageNamed:_iconName];
//    self.iconImageView.hidden = FALSE;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.textField becomeFirstResponder];
}

- (IBAction)cancel:(id)sender {
    [self.delegate listDetailViewControllerDidCancel:self];
}

- (IBAction)done:(id)sender {
    if (self.checklistToEdit == nil) {
        Checklist *checklist = [[Checklist alloc]init];
        checklist.name = self.textField.text;
        checklist.iconName = _iconName;
        
        [self.delegate listDetailViewController:self didFinishAddingChecklist:checklist];
    } else {
        self.checklistToEdit.name = self.textField.text;
        self.checklistToEdit.iconName = _iconName;
        
        [self.delegate listDetailViewController:self didFinishEditingChecklist:self.checklistToEdit];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return indexPath;
    } else {
        return nil;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.doneBarButton.enabled =([newText length] > 0);
    return YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // 通知IconPickerViewController该界面将成为它的代理对象
    if ([segue.identifier isEqualToString:@"PickIcon"]) {
        IconPickerViewController *controller = segue.destinationViewController;
        controller.delegate = self;
    }
}

// 实现代理协议的回调方法
- (void)iconPicker:(IconPickerViewController *)picker didPickIcon:(NSString *)iconName {
    _iconName = iconName;
    self.iconImageView.image = [UIImage imageNamed:_iconName];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
