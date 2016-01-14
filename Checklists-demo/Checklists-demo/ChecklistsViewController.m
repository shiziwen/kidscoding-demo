//
//  ViewController.m
//  Checklists-demo
//
//  Created by mac on 15/12/18.
//  Copyright © 2015年 shiziwen. All rights reserved.
//

#import "ChecklistsViewController.h"
#import "ChecklistItem.h"
#import "Checklist.h"

@interface ChecklistsViewController ()

@end

@implementation ChecklistsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.checklist.name;
    
    // Do any additional setup after loading the view, typically from a nib.
//    _items = [[NSMutableArray alloc]initWithCapacity:20];
//    
//    BOOL checkedDefault = NO;
//    
//    ChecklistItem *item;
//    
//    item = [[ChecklistItem alloc]init];
//    item.text = @"text1";
//    item.checked = checkedDefault;
//    [_items addObject:item];
//    
//    item = [[ChecklistItem alloc]init];
//    item.text = @"text2";
//    item.checked = checkedDefault;
//    [_items addObject:item];
//    
//    item = [[ChecklistItem alloc]init];
//    item.text = @"text3";
//    item.checked = checkedDefault;
//    [_items addObject:item];
//    
//    item = [[ChecklistItem alloc]init];
//    item.text = @"text4";
//    item.checked = checkedDefault;
//    [_items addObject:item];
//    
//    item = [[ChecklistItem alloc]init];
//    item.text = @"text5";
//    item.checked = checkedDefault;
//    [_items addObject:item];
    
}

// 缓存目录
- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    
    return documentsDirectory;
}


- (void)didReceiveMemoryWarning {
    NSLog(@"did receive");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.checklist.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"indexpath.row = %ld", indexPath.row);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChecklistItem"];
    
    ChecklistItem *item = self.checklist.items[indexPath.row];
    
    [self configureCheckmarkForCell:cell withChecklistItem:item];
    [self configureTextForCell:cell withChecklistItem:item];
    
    return cell;
}

// 点击行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    ChecklistItem *item = self.checklist.items[indexPath.row];

    [item toggleChecked];
    [self configureCheckmarkForCell:cell withChecklistItem:item];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)configureItemForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    ChecklistItem *item = self.checklist.items[indexPath.row];
    
    if (item.checked) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

// 配置checkitem的lchecked
- (void)configureCheckmarkForCell:(UITableViewCell *)cell withChecklistItem:(ChecklistItem *)item {
    UILabel *label = (UILabel *)[cell viewWithTag:1001];
    
    if (item.checked) {
        label.text = @"√";
    } else {
        label.text = @"";
    }
}

// 配置checkitem的text
- (void)configureTextForCell:(UITableViewCell *)cell withChecklistItem:(ChecklistItem *)item {
    UILabel *label = (UILabel *)[cell viewWithTag:1000];
//    label.text = item.text;
    label.text = [NSString stringWithFormat:@"%ld: %@", (long)item.itemId, item.text];
}

// 滑动删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.checklist.items removeObjectAtIndex:indexPath.row];
    
    NSArray *indexPaths = @[indexPath];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

// 代理实现
- (void)itemDetailViewControllerDidCancel:(ItemDetailViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)itemDetailViewController:(ItemDetailViewController *)controller didFinishAddingItem:(ChecklistItem *)item {
    NSInteger newRowIndex = [self.checklist.items count];
    [self.checklist.items addObject:item];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:newRowIndex inSection:0];
    NSArray *indexPaths = @[indexPath];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)itemDetailViewController:(ItemDetailViewController *)controller didFinishEditingItem:(ChecklistItem *)item {
    NSInteger index = [self.checklist.items indexOfObject:item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    [self configureTextForCell:cell withChecklistItem:item];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 赋值代理
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddItem"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        ItemDetailViewController *controller = (ItemDetailViewController *)navigationController.topViewController;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"EditItem"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        ItemDetailViewController *controller = (ItemDetailViewController *)navigationController.topViewController;
        controller.delegate = self;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        controller.itemToEdit = self.checklist.items[indexPath.row];
        
    }
}
@end
