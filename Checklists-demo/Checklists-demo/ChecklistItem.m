//
//  ChecklitItem.m
//  Checklists-demo
//
//  Created by mac on 15/12/19.
//  Copyright © 2015年 shiziwen. All rights reserved.
//

#import "ChecklistItem.h"
#import "DataModel.h"

@implementation ChecklistItem

- (id)init {
    if ((self = [super init])) {
        self.itemId = [DataModel nextChecklistItemId];
    }
    return self;
}

- (void)toggleChecked {
    self.checked = !self.checked;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.text = [aDecoder decodeObjectForKey:@"Text"];
        self.checked = [aDecoder decodeBoolForKey:@"Checked"];
        self.dueDate = [aDecoder decodeObjectForKey:@"DueDate"];
        self.shouldRemind = [aDecoder decodeBoolForKey:@"ShouldRemind"];
        self.itemId = [aDecoder decodeIntegerForKey:@"ItemID"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.text forKey:@"Text"];
    [aCoder encodeBool:self.checked forKey:@"Checked"];
    [aCoder encodeObject:self.dueDate forKey:@"DueDate"];
    [aCoder encodeBool:self.shouldRemind forKey:@"ShouldRemind"];
    [aCoder encodeInteger:self.itemId forKey:@"ItemID"];
}

- (void)scheduleNotification {
    UILocalNotification *exisitingNotification = [self notificationForThisItem];
    if (exisitingNotification != nil) {
        NSLog(@"Found exist notification %@", exisitingNotification);
        [[UIApplication sharedApplication] cancelLocalNotification:exisitingNotification];
    }
    
    if (self.shouldRemind && [self.dueDate compare:[NSDate date]] != NSOrderedAscending) {
//        NSLog(@"added one notification");
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = self.dueDate;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.alertBody = self.text;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.userInfo = @{@"ItemID": @(self.itemId)};
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        NSLog(@"schedule notification %@ for itemId %ld", localNotification, self.itemId);
    }
}

- (UILocalNotification *)notificationForThisItem {
    NSArray *allNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in allNotifications) {
        NSNumber *number = [notification.userInfo objectForKey:@"ItemID"];
        if (number != nil && [number integerValue] == self.itemId) {
            return notification;
        }
    }
    return nil;
}

- (void)dealloc {
    UILocalNotification *exisitingNotification = [self notificationForThisItem];
    if (exisitingNotification != nil) {
        NSLog(@"remove existing notification %@", exisitingNotification);
        [[UIApplication sharedApplication] cancelLocalNotification:exisitingNotification];
    }
}

@end
