//
//  ViewController.m
//  Checklists-demo
//
//  Created by mac on 15/12/18.
//  Copyright © 2015年 shiziwen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    NSMutableArray *_items;
}

- (void)viewDidLoad {
    NSLog(@"did load");
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    _items = [[NSMutableArray alloc]initWithCapacity:20];
    
    BOOL checkedDefault = NO;
    
    ChecklitItem *item;
    
    item = [[ChecklitItem alloc]init];
    item.text = @"text1";
    item.checked = checkedDefault;
    [_items addObject:item];
    
    item = [[ChecklitItem alloc]init];
    item.text = @"text2";
    item.checked = checkedDefault;
    [_items addObject:item];
    
    item = [[ChecklitItem alloc]init];
    item.text = @"text3";
    item.checked = checkedDefault;
    [_items addObject:item];
    
    item = [[ChecklitItem alloc]init];
    item.text = @"text4";
    item.checked = checkedDefault;
    [_items addObject:item];
    
    item = [[ChecklitItem alloc]init];
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
    
    ChecklitItem *item = _items[indexPath.row];
    
    [self configureCheckmarkForCell:cell withChecklistItem:item];
    [self configureTextForCell:cell withChecklistItem:item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    ChecklitItem *item = _items[indexPath.row];

    [item toggleChecked];
    [self configureCheckmarkForCell:cell withChecklistItem:item];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)configureItemForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    ChecklitItem *item = _items[indexPath.row];
    
    if (item.checked) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)configureCheckmarkForCell:(UITableViewCell *)cell withChecklistItem:(ChecklitItem *)item {
    if (item.checked) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)configureTextForCell:(UITableViewCell *)cell withChecklistItem:(ChecklitItem *)item {
    UILabel *label = (UILabel *)[cell viewWithTag:1000];
    label.text = item.text;
}

- (IBAction)addItem:(id)sender {
    NSInteger newRowIndex = [_items count];
    ChecklitItem *item = [[ChecklitItem alloc]init];
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
@end
