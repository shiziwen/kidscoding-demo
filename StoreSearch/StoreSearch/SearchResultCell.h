//
//  SearchResultCell.h
//  StoreSearch
//
//  Created by mac on 16/2/10.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResult;

@interface SearchResultCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

- (void)configureForSearchResult:(SearchResult *)searchResult;
@end
