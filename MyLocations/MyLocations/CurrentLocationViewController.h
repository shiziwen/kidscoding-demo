//
//  FirstViewController.h
//  MyLocations
//
//  Created by mac on 16/1/16.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrentLocationViewController : UIViewController
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *longtitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UIButton *tagButton;
@property (nonatomic, weak) IBOutlet UIButton *getButton;

@end

