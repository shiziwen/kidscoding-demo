//
//  SearchResult.h
//  StoreSearch
//
//  Created by mac on 16/2/9.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchResult : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *artistName;

@property (nonatomic, copy) NSString *artworkURL60;
@property (nonatomic, copy) NSString *artworkURL100;
@property (nonatomic, copy) NSString *storeURL;
@property (nonatomic, copy) NSString *kind;
@property (nonatomic, copy) NSString *currency;
@property (nonatomic, copy) NSString *genre;
@property (nonatomic, copy) NSDecimalNumber *price;

- (NSComparisonResult)compareName:(SearchResult *)other;
@end
