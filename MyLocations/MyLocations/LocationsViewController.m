//
//  LocationsViewController.m
//  MyLocations
//
//  Created by mac on 16/1/21.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import "LocationsViewController.h"
#import "Location.h"
#import "LocationCell.h"
#import "LocationDetailViewController.h"
#import "UIImage+Resize.h"
#import "NSMutableString+AddText.h"

@interface LocationsViewController () <NSFetchedResultsControllerDelegate>

@end

@implementation LocationsViewController {
//    NSArray *_locations;
    NSFetchedResultsController *_fetchedResultController;
}

- (NSFetchedResultsController *)fetchedResultController {
    if (_fetchedResultController == nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
        
        [fetchRequest setFetchBatchSize:20];
        
        _fetchedResultController = [[NSFetchedResultsController alloc]
                                    initWithFetchRequest:fetchRequest
                                    managedObjectContext:self.managedObjectContext
                                    sectionNameKeyPath:@"category"
                                    cacheName:@"Locations"];
        
        _fetchedResultController.delegate = self;
    }
    
    return _fetchedResultController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    
    [NSFetchedResultsController deleteCacheWithName:@"Locations"];
    [self performFetch];
    
}

- (void)performFetch {
    NSError *error;
    if (![self.fetchedResultController performFetch:&error]) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Location"];
    
//    Location *location = [_locations objectAtIndex:indexPath.row];
//    
//    UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:100];
//    descriptionLabel.text = location.locationDescription;
//    
//    UILabel *addressLabel = (UILabel *)[cell viewWithTag:101];
//    addressLabel.text = [NSString stringWithFormat:@"%@ %@, %@",
//                         location.placemark.subThoroughfare,
//                         location.placemark.thoroughfare,
//                         location.placemark.locality
//                         ];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultController sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultController sections][section];
    return [[sectionInfo name] uppercaseString];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Location *location = [self.fetchedResultController objectAtIndexPath:indexPath];
        [location removePhotoFile];
        [self.managedObjectContext deleteObject:location];
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            FATAL_CORE_DATA_ERROR(error);
            return;
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    LocationCell *locationCell = (LocationCell *)cell;
    Location *location = [self.fetchedResultController objectAtIndexPath:indexPath];
    
    if ([location.locationDescription length] > 0) {
        locationCell.descriptionLabel.text = location.locationDescription;
    } else {
        locationCell.descriptionLabel.text = @"(No Description)";
    }
    
    if (location.placemark != nil) {
        NSMutableString *line = [NSMutableString stringWithCapacity:100];
        [line addText:location.placemark.subThoroughfare withSeparator:@""];
        [line addText:location.placemark.thoroughfare withSeparator:@" "];
        [line addText:location.placemark.locality withSeparator:@", "];
        locationCell.addressLabel.text = line;
    } else {
        locationCell.addressLabel.text = [NSString stringWithFormat:@"Lat: %.8f, Long: %.8f",
                                          [location.latitude doubleValue],
                                          [location.longitude doubleValue]];
    }
    
    UIImage *image = nil;
    if ([location hasPhoto]) {
        image = [location photoImage];
        if (image != nil) {
            image = [image resizedImageWithBounds:CGSizeMake(52, 52)];
        }
    }
    
    if (image == nil) {
        image = [UIImage imageNamed:@"No Photo"];
    }
    
    locationCell.photoImageView.image = image;
    
    locationCell.backgroundColor = [UIColor blackColor];
    locationCell.descriptionLabel.textColor = [UIColor whiteColor];
    locationCell.descriptionLabel.highlightedTextColor = locationCell.descriptionLabel.textColor;
    locationCell.addressLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    locationCell.addressLabel.highlightedTextColor = locationCell.addressLabel.textColor;
    
    UIView *selectionView = [[UIView alloc] initWithFrame:CGRectZero];
    selectionView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    locationCell.selectedBackgroundView = selectionView;
    
    locationCell.photoImageView.layer.cornerRadius = locationCell.photoImageView.bounds.size.width / 2.0f;
    locationCell.photoImageView.clipsToBounds = YES;
    locationCell.separatorInset = UIEdgeInsetsMake(0, 82, 0, 0);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, tableView.sectionHeaderHeight - 14.0f, 300.0f, 14.0f)];
    label.font = [UIFont boldSystemFontOfSize:11.0f];
    label.text = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
    label.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    label.backgroundColor = [UIColor clearColor];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(15.0f, tableView.sectionHeaderHeight - 0.5f, tableView.bounds.size.width - 15.0f, 0.5f)];
    separator.backgroundColor = tableView.separatorColor;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, tableView.sectionHeaderHeight)];
    view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.85f];
    [view addSubview:label];
    [view addSubview:separator];

    return view;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditLocation"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        LocationDetailViewController *controller = (LocationDetailViewController *)navigationController.topViewController;
        
        controller.managedObjectContext = self.managedObjectContext;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Location *location = [self.fetchedResultController objectAtIndexPath:indexPath];
        controller.locationToEdit = location;
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"controllerWillChangeContent");
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"*** NSFetchedResultsChangeInsert");
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        
        case NSFetchedResultsChangeDelete:
            NSLog(@"*** NSFetchedResultsChangeDelete");
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"*** NSFetchedResultsChangeUpdate");
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            NSLog(@"*** NSFetchedResultsChangeMove");
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"*** NSFetchedResultsChangeInsert (section)");
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        
        case NSFetchedResultsChangeDelete:
            NSLog(@"*** NSFetchedResultsChangeDelete (section)");
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"controllerDidChangeContent");
    [self.tableView endUpdates];
}

/*It’s always a good idea to explicitly set the delegate to nil when you no longer need the NSFetchedResultsController, 
 just so you don’t get any more notifications that were still pending.
 */
- (void)dealloc {
    _fetchedResultController.delegate = nil;
}
@end
