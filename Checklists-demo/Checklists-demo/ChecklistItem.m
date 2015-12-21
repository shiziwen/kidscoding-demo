//
//  ChecklitItem.m
//  Checklists-demo
//
//  Created by mac on 15/12/19.
//  Copyright © 2015年 shiziwen. All rights reserved.
//

#import "ChecklistItem.h"

@implementation ChecklistItem

- (void)toggleChecked {
    self.checked = !self.checked;
}

@end
