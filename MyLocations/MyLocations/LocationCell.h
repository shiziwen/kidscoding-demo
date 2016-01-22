//
//  LocationCell.h
//  MyLocations
//
//  Created by mac on 16/1/21.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end
