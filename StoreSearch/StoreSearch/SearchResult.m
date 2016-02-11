//
//  SearchResult.m
//  StoreSearch
//
//  Created by mac on 16/2/9.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import "SearchResult.h"

@implementation SearchResult

- (NSComparisonResult)compareName:(SearchResult *)other {
    return [self.name localizedStandardCompare:other.name];
}

@end
