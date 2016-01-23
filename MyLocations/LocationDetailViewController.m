//
//  LocationDetailViewController.m
//  MyLocations
//
//  Created by mac on 16/1/19.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "LocationDetailViewController.h"
#import "CategoryPickerViewController.h"
#import "HudView.h"
#import "Location.h"
#import "NSMutableString+AddText.h"

@interface LocationDetailViewController () <UITextViewDelegate, UIImagePickerControllerDelegate,
                                            UINavigationControllerDelegate>
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *addessLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *photoLabel;

@end

@implementation LocationDetailViewController {
    NSString *_descriptionText;
    NSString *_categoryName;
    NSDate *_date;
    UIImage *_image;
    
    UIActionSheet *_actionSheet;
    UIImagePickerController *_imagePicker;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        _descriptionText = @"";
        _categoryName = @"No Category";
        _date = [NSDate date];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidEnterBackground {
    if (_imagePicker != nil) {
        [self dismissViewControllerAnimated:nil completion:nil];
        _imagePicker = nil;
    }
    if (_actionSheet != nil) {
        [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:NO];
        _actionSheet = nil;
    }
    
    [self.descriptionTextView resignFirstResponder];
}

- (IBAction)done:(id)sender {
    NSLog(@"description is %@", _descriptionText);
    
    HudView *hudView = [HudView hudInView:self.navigationController.view animated:YES];

    Location *location;
    if (self.locationToEdit != nil) {
        hudView.text = @"Updated";
        location = self.locationToEdit;
    } else {
        hudView.text = @"Tagged";
        location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        location.photoId = @-1;
    }
    
    location.locationDescription = _descriptionText;
    location.category = _categoryName;
    location.latitude = @(self.coordinate.latitude);
    location.longitude = @(self.coordinate.longitude);
    location.date = _date;
    location.placemark = _placemark;
    
    NSLog(@"place is %@", _placemark);
    
    if (_image != nil) {
        if (![location hasPhoto]) {
            location.photoId = @([Location nextPhotoId]);
        }
        
        NSData *data = UIImageJPEGRepresentation(_image, 0.5);
        NSError *error;
        if (![data writeToFile:[location photoPath] options:NSDataWritingAtomic error:&error]) {
            NSLog(@"Error writing file: %@", error);
        }
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"*** Error: %@", error);
        FATAL_CORE_DATA_ERROR(error);
//        abort();
//        return;
    }
    
    [self performSelector:@selector(closeScreen) withObject:nil afterDelay:0.6];
}

- (IBAction)cancel:(id)sender {
    [self closeScreen];
}

- (void)closeScreen {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 代替代理实现保存categoryName
- (IBAction)categoryPickerDidPickCategory:(UIStoryboardSegue *)segue {
    CategoryPickerViewController *viewController = segue.sourceViewController;
    _categoryName = viewController.selectedCategoryName;
    self.categoryLabel.text = _categoryName;
}

- (void)showImage:(UIImage *)image {
    self.imageView.image = image;
    self.imageView.hidden = NO;
    self.imageView.frame = CGRectMake(10, 10, 260, 260);
    self.photoLabel.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.locationToEdit != nil) {
        self.title = @"Edit Location";
        
        if ([self.locationToEdit hasPhoto]) {
            UIImage *existingImage = [self.locationToEdit photoImage];
            if (existingImage != nil) {
                [self showImage:existingImage];
            }
        }
    }
    
    self.descriptionTextView.text = _descriptionText;
    self.categoryLabel.text = _categoryName;
    
    self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", self.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", self.coordinate.longitude];
    
    if (self.placemark != nil) {
        self.addessLabel.text = [self stringFromPlacemark:self.placemark];
    } else {
        self.addessLabel.text = @"No Address Found";
    }
    
    self.dateLabel.text = [self formateDate:_date];
    
    // 添加触碰操作处理
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    
    self.descriptionTextView.textColor = [UIColor whiteColor];
    self.descriptionTextView.backgroundColor = [UIColor blackColor];
    
    self.photoLabel.textColor = [UIColor whiteColor];
    self.photoLabel.highlightedTextColor = self.photoLabel.textColor;
    
    self.addessLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    self.addessLabel.highlightedTextColor = self.addessLabel.textColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLocationToEdit:(Location *)newLocationToEdit {
    if (_locationToEdit != newLocationToEdit) {
        _locationToEdit = newLocationToEdit;
        
        _descriptionText = _locationToEdit.locationDescription;
        _categoryName = _locationToEdit.category;
        _date = _locationToEdit.date;
        
        self.coordinate = CLLocationCoordinate2DMake([_locationToEdit.latitude doubleValue],
                                                      [_locationToEdit.longitude doubleValue]);
        self.placemark = _locationToEdit.placemark;
        
    }
}

- (NSString *)stringFromPlacemark:(CLPlacemark *)placemark {
    NSMutableString *line = [NSMutableString stringWithCapacity:100];
    [line addText:placemark.subThoroughfare withSeparator:@""];
    [line addText:placemark.thoroughfare withSeparator:@" "];
    [line addText:placemark.locality withSeparator:@", "];
    [line addText:placemark.administrativeArea withSeparator:@", "];
    [line addText:placemark.postalCode withSeparator:@" "];
    [line addText:placemark.country withSeparator:@", "];
    
    return line;
}

- (NSString *)formateDate:(NSDate *)theDate {
    static NSDateFormatter *formatter = nil;
    
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    return [formatter stringFromDate:theDate];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"PickCategory"]) {
        CategoryPickerViewController *controller = segue.destinationViewController;
        controller.selectedCategoryName = _categoryName;
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"imageView hidden is %d", self.imageView.hidden);
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 88;
    } else if (indexPath.section == 1) {
        if (self.imageView.hidden) {
            return 44;
        } else {
            return 280;
        }
    } else if (indexPath.section == 2 && indexPath.row == 2) {
        CGRect rect = CGRectMake(100, 10, 205, 10000);
        self.addessLabel.frame = rect;
        [self.addessLabel sizeToFit];
        
        rect.size.height = self.addessLabel.frame.size.height;
        self.addessLabel.frame = rect;
        
        return self.addessLabel.frame.size.height + 20;
    } else {
        return 44;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || indexPath.section == 1) {
        return indexPath;
    } else {
        return nil;
    }
}

- (void)takePhoto {
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    _imagePicker.view.tintColor = self.view.tintColor;
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (void)choosePhotoFromLibrary {
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    _imagePicker.view.tintColor = self.view.tintColor;
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (void)showPhotoMenu {
    if (YES || [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"action sheet");
        
        _actionSheet = [[UIActionSheet alloc]
                        initWithTitle:nil
                        delegate:self
                        cancelButtonTitle:@"Cancel"
                        destructiveButtonTitle:nil
                        otherButtonTitles:@"Take Photo", @"Choose from Library", nil];
        [_actionSheet showInView:self.view];
    } else {
        [self choosePhotoFromLibrary];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self.descriptionTextView becomeFirstResponder];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
//        [self takePhoto];
//        [self choosePhotoFromLibrary];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self showPhotoMenu];
    }
}


# pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    _descriptionText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    _descriptionText = textView.text;
}

- (void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    if (indexPath != nil && indexPath.section == 0 && indexPath.row == 0) {
        return;
    }
    
    [self.descriptionTextView resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor blackColor];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    cell.detailTextLabel.highlightedTextColor = cell.detailTextLabel.textColor;
    
    UIView *selectionView = [[UIView alloc] initWithFrame:CGRectZero];
    selectionView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    cell.selectedBackgroundView = selectionView;
    
    if (indexPath.row == 2) {
        UILabel *addressLabel = (UILabel *)[cell viewWithTag:100];
        addressLabel.textColor = [UIColor whiteColor];
        addressLabel.highlightedTextColor = addressLabel.textColor;
    }
}

/*
 The view controller must conform to both UIImagePickerControllerDelegate and UINavigationControllerDelegate 
 for this to work, but you don’t have to implement any of the UINavigationControllerDelegate methods.
 */

# pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    _image = info[UIImagePickerControllerEditedImage];
    [self showImage:_image];
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    _imagePicker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    _imagePicker = nil;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self takePhoto];
    } else if (buttonIndex == 1) {
        [self choosePhotoFromLibrary];
    }
    
    _actionSheet = nil;
}

@end
