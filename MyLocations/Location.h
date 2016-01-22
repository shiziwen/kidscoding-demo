//
//  Location.h
//  MyLocations
//
//  Created by mac on 16/1/20.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Location : NSManagedObject <MKAnnotation>

// Insert code here to declare functionality of your managed object subclass
+ (NSInteger)nextPhotoId;

- (BOOL)hasPhoto;
- (NSString *)photoPath;
- (UIImage *)photoImage;
- (void)removePhotoFile;

@end

NS_ASSUME_NONNULL_END

#import "Location+CoreDataProperties.h"
