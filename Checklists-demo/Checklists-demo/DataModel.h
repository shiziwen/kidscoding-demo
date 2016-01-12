//
//  DataModel.h
//  Checklists-demo
//
//  Created by mac on 16/1/13.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject
@property (nonatomic, strong) NSMutableArray *lists;

- (void)saveChecklists;

- (NSInteger)indexOfSelectedChecklist;
- (void)setIndexOfSelectedChecklist:(NSInteger)index;
- (void)sortChecklists;
@end
