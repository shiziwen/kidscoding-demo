//
//  ChecklitItem.h
//  Checklists-demo
//
//  Created by mac on 15/12/19.
//  Copyright © 2015年 shiziwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ChecklistItem : NSObject

@property(atomic, copy)NSString *text;
@property(atomic, assign)BOOL checked;
@property (nonatomic, copy) NSDate *dueDate;
@property (nonatomic, assign) BOOL shouldRemind;
@property (nonatomic, assign) NSInteger itemId;

- (void) toggleChecked;

- (void)scheduleNotification;

@end
