//
//  AllListsViewController.m
//  Checklists-demo
//
//  Created by mac on 15/12/28.
//  Copyright © 2015年 shiziwen. All rights reserved.
//

#import "AllListsViewController.h"
#import "Checklist.h"
#import "ChecklistsViewController.h"
#import "ChecklistItem.h"

@interface AllListsViewController ()

@end

@implementation AllListsViewController
{
    NSMutableArray *_lists;
}

- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    
    return documentsDirectory;
}

- (NSString *)dataFilePath {
    return [[self documentsDirectory]stringByAppendingPathComponent:@"Checklists.plist"];
}

- (void)saveChecklists {
    NSMutableData *data = [[NSMutableData alloc]init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:_lists forKey:@"ChecklistItems"];
    [archiver finishEncoding];
    [data writeToFile:[self dataFilePath] atomically:YES];
}

- (void)loadChecklists {
    NSString *path = [self dataFilePath];

    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        NSData *data = [[NSData alloc]initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        _lists = [unarchiver decodeObjectForKey:@"ChecklistItems"];
        [unarchiver finishDecoding];
    } else {
        _lists = [[NSMutableArray alloc]initWithCapacity:20];
    }
}

// 从storyboard中加载视图控制器
- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self loadChecklists];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"file is %@", [self dataFilePath]);
    
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_lists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Checklist *checklist = _lists[indexPath.row];
    cell.textLabel.text = checklist.name;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}

// show checklist
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Checklist *checklist = _lists[indexPath.row];
    [self performSegueWithIdentifier:@"ShowChecklist" sender:checklist];
}

// 将checklist对象传递给ChecklistViewController
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowChecklist"]) {
        ChecklistsViewController *controller = segue.destinationViewController;
        controller.checklist = sender;
    } else if ([segue.identifier isEqualToString:@"AddChecklist"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        ListDetailViewController *controller = (ListDetailViewController *)navigationController.topViewController;
        controller.delegate = self;
        controller.checklistToEdit = nil;
    }
    
}

// 代理实现
- (void)listDetailViewControllerDidCancel:(ListDetailViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)listDetailViewController:(ListDetailViewController *)controller
        didFinishAddingChecklist:(Checklist *)checklist {
    NSInteger newRowIndex = [_lists count];
    [_lists addObject:checklist];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newRowIndex inSection:0];
    NSArray *indexPaths = @[indexPath];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)listDetailViewController:(ListDetailViewController *)controller
       didFinishEditingChecklist:(Checklist *)checklist {
    NSInteger index = [_lists indexOfObject:checklist];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = checklist.name;
    [self dismissViewControllerAnimated:YES completion:nil];
}

// delete
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [_lists removeObjectAtIndex:indexPath.row];
    NSArray *indexPaths = @[indexPath];
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

// 打开编辑界面
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"accessoryButtonTappedForRowWithIndexPath");
    
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"ListNavigationController"];
    
    ListDetailViewController *controller = (ListDetailViewController *)navigationController.topViewController;
    controller.delegate = self;
    
    Checklist *checklist = _lists[indexPath.row];
    controller.checklistToEdit = checklist;

    [self presentViewController:navigationController animated:YES completion:nil];
}
@end
