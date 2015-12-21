//
//  ViewController.m
//  Checklists-demo
//
//  Created by mac on 15/12/18.
//  Copyright © 2015年 shiziwen. All rights reserved.
//

#import "ChecklistsViewController.h"

@interface ChecklistsViewController ()

@end

@implementation ChecklistsViewController {
    NSMutableArray *_items;
}

- (void)viewDidLoad {
    NSLog(@"did load");
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    _items = [[NSMutableArray alloc]initWithCapacity:20];
    
    BOOL checkedDefault = NO;
    
    ChecklistItem *item;
    
    item = [[ChecklistItem alloc]init];
    item.text = @"text1";
    item.checked = checkedDefault;
    [_items addObject:item];
    
    item = [[ChecklistItem alloc]init];
    item.text = @"text2";
    item.checked = checkedDefault;
    [_items addObject:item];
    
    item = [[ChecklistItem alloc]init];
    item.text = @"text3";
    item.checked = checkedDefault;
    [_items addObject:item];
    
    item = [[ChecklistItem alloc]init];
    item.text = @"text4";
    item.checked = checkedDefault;
    [_items addObject:item];
    
    item = [[ChecklistItem alloc]init];
    item.text = @"text5";
    item.checked = checkedDefault;
    [_items addObject:item];
    
}

- (void)didReceiveMemoryWarning {
    NSLog(@"did receive");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"indexpath.row = %ld", indexPath.row);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChecklistItem"];
    
    ChecklistItem *item = _items[indexPath.row];
    
    [self configureCheckmarkForCell:cell withChecklistItem:item];
    [self configureTextForCell:cell withChecklistItem:item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    ChecklistItem *item = _items[indexPath.row];

    [item toggleChecked];
    [self configureCheckmarkForCell:cell withChecklistItem:item];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)configureItemForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    ChecklistItem *item = _items[indexPath.row];
    
    if (item.checked) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)configureCheckmarkForCell:(UITableViewCell *)cell withChecklistItem:(ChecklistItem *)item {
    UILabel *label = (UILabel *)[cell viewWithTag:1001];
    
    if (item.checked) {
        label.text = @"√";
    } else {
        label.text = @"";
    }
}

- (void)configureTextForCell:(UITableViewCell *)cell withChecklistItem:(ChecklistItem *)item {
    UILabel *label = (UILabel *)[cell viewWithTag:1000];
    label.text = item.text;
}

- (IBAction)addItem:(id)sender {
    NSInteger newRowIndex = [_items count];
    ChecklistItem *item = [[ChecklistItem alloc]init];
    item.text = @"new text";
    item.checked = NO;
    [_items addObject:item];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newRowIndex inSection:0];
    NSArray *indexPaths = @[indexPath];
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [_items removeObjectAtIndex:indexPath.row];
    
    NSArray *indexPaths = @[indexPath];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

// 代理实现
- (void)addItemViewControllerDidCancel:(AddItemViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addItemViewController:(AddItemViewController *)controller didFinishAddingItem:(ChecklistItem *)item {
    NSInteger newRowIndex = [_items count];
    [_items addObject:item];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:newRowIndex inSection:0];
    NSArray *indexPaths = @[indexPath];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addItemVIewcontroller:(AddItemViewController *)controller didFinishEditingItem:(ChecklistItem *)item {
    NSInteger index = [_items indexOfObject:item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    [self configureTextForCell:cell withChecklistItem:item];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 赋值代理
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddItem"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        AddItemViewController *controller = (AddItemViewController *)navigationController.topViewController;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"EditItem"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        AddItemViewController *controller = (AddItemViewController *)navigationController.topViewController;
        controller.delegate = self;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        controller.itemToEdit = _items[indexPath.row];
        
    }
}
@end
