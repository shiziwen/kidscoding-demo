//
//  Checklist.h
//  Checklists-demo
//
//  Created by mac on 15/12/28.
//  Copyright © 2015年 shiziwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Checklist : NSObject<NSCoding>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableArray *items;

- (int)countUncheckedItems;
@end
