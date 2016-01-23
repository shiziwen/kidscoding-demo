//
//  FirstViewController.h
//  MyLocations
//
//  Created by mac on 16/1/16.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CurrentLocationViewController : UIViewController<CLLocationManagerDelegate>
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UIButton *tagButton;
@property (nonatomic, weak) IBOutlet UIButton *getButton;

@property (nonatomic, weak) IBOutlet UILabel *latitudeTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *longitudeTextLabel;
@property (nonatomic, weak) IBOutlet UIView *containerView;

- (IBAction)getLocation:(id)sender;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

