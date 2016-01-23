//
//  CategoryPickerViewController.m
//  MyLocations
//
//  Created by mac on 16/1/19.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import "CategoryPickerViewController.h"

@interface CategoryPickerViewController ()

@end

@implementation CategoryPickerViewController {
    NSArray *_categories;
    NSIndexPath *_selectedIndexPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _categories = @[
                @"No Category",
                @"Apple Store",
                @"Bar",
                @"BookStore",
                @"Club",
                @"Grocery Store",
                @"Historic Building",
                @"House",
                @"Icecream Vender",
                @"Landmark",
                @"Park"
                ];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_categories count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    // Configure the cell...
    NSString *categoryName = _categories[indexPath.row];
    cell.textLabel.text = categoryName;
    
    if ([categoryName isEqualToString:self.selectedCategoryName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor blackColor];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
    
    UIView *selectionView = [[UIView alloc] initWithFrame:CGRectZero];
    selectionView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    cell.selectedBackgroundView = selectionView;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != _selectedIndexPath.row) {
        NSLog(@"didSelectRowAtIndexPath");
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:_selectedIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        
        _selectedIndexPath = indexPath;
//        NSLog(@"_selectedIndexPath is %ld", _selectedIndexPath.row);
    }
}

// 当触发unwind segue时根据所选择的行获得selectedCategoryName属性
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"prepareForSegue check PickedCategory");
    if ([segue.identifier isEqualToString:@"PickedCategory"]) {
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        self.selectedCategoryName = _categories[indexPath.row];
    }
}
@end
