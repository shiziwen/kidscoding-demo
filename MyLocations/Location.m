//
//  Location.m
//  MyLocations
//
//  Created by mac on 16/1/20.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import "Location.h"

@implementation Location

// Insert code here to add functionality to your managed object subclass

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (NSString *)title {
    return [self.locationDescription length] > 0 ? self.locationDescription : @"(No Description)";
}

- (NSString *)subtitle {
    return self.category;
}
@end
