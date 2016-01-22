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

- (BOOL)hasPhoto {
    return (self.photoId != nil) && ([self.photoId integerValue] != -1);
}

- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirecory = [paths lastObject];
    return documentsDirecory;
}

- (NSString *)photoPath {
    NSString *filename = [NSString stringWithFormat:@"Photo-%ld.jpg", [self.photoId integerValue]];
    return [[self documentsDirectory] stringByAppendingPathComponent:filename];
}

- (UIImage *)photoImage {
    NSAssert(self.photoId != nil, @"No photo ID set");
    NSAssert([self.photoId integerValue] != -1, @"Photo ID is -1");
    
    return [UIImage imageWithContentsOfFile:[self photoPath]];
}

+ (NSInteger)nextPhotoId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger photoId = [defaults integerForKey:@"PhotoID"];
    [defaults setInteger:photoId+1 forKey:@"PhotoID"];
    [defaults synchronize];
    return photoId;
}

- (void)removePhotoFile {
    NSString *path = [self photoPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error;
        if (![fileManager removeItemAtPath:path error:&error]) {
            NSLog(@"Error removing file: %@", error);
        }
    }
}

@end
