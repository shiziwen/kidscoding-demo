//
//  SearchViewController.m
//  StoreSearch
//
//  Created by mac on 16/1/25.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResult.h"
#import "SearchResultCell.h"

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NothingFoundCellIdentifier = @"NothingFoundCell";

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation SearchViewController {
    NSMutableArray *_searchResults;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.tableView.rowHeight = 80;
    
    UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    
    cellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
    
    [self.searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchResults == nil) {
        return 0;
    } else if ([_searchResults count] == 0) {
        return 1;
    } else {
        return [_searchResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier = @"SearchResultCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//    }
    
    if ([_searchResults count] == 0) {
        return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier forIndexPath:indexPath];
    } else {
        SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier];
        
        SearchResult *searchResult = _searchResults[indexPath.row];
        cell.nameLabel.text = searchResult.name;
        cell.artistNameLabel.text = searchResult.artistName;
        
        return cell;

    }
    
}

#pragma mark - UISearchBarDelegate

- (void)showNetworkError {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Whoops..."
                              message:@"There was an error reading from the iTunes Store. Please try again"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    
    [alertView show];
    
}

- (NSDictionary *)parseJson:(NSString *)jsonString {
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    id resultObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (resultObject == nil) {
        NSLog(@"Json error: %@", error);
        return nil;
    }
    
    if (![resultObject isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Json error: Expected Dictionary");
        return nil;
    }
    
    return resultObject;
}

- (NSURL *)urlWithSearchText:(NSString *)searchText {
    NSString *escapedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@", escapedSearchText];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    return url;
}

- (NSString *)performStoreRequestWithUrl:(NSURL *)url {
    NSError *error;
    NSString *resultString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (resultString == nil) {
        NSLog(@"Fetch error is %@", error);
        return nil;
    }
    
    return resultString;
}

- (void)parseDictionary:(NSDictionary *)dictionary {
    NSArray *array = dictionary[@"results"];
    if (array == nil) {
        NSLog(@"Expected results array");
        return;
    }
    
    for (NSDictionary *resultDict in array) {
        NSLog(@"wrapperType: %@, kind: %@", resultDict[@"wrapperType"], resultDict[@"kind"]);
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if ([searchBar.text length] > 0) {
        [searchBar resignFirstResponder];
        _searchResults = [NSMutableArray arrayWithCapacity:10];
        
        NSURL *url = [self urlWithSearchText:searchBar.text];
        NSLog(@"URL is %@", url);
        
        NSString *jsonString = [self performStoreRequestWithUrl:url];
        NSLog(@"Received JSON string: %@", jsonString);
        if (jsonString == nil) {
            [self showNetworkError];
            return;
        }
        
        NSDictionary *dictionary = [self parseJson:jsonString];
        if (dictionary == nil) {
            [self showNetworkError];
            return;
        }
        
        NSLog(@"Dictionary: %@", dictionary);
        
        [self parseDictionary:dictionary];

        
        [self.tableView reloadData];
    }
    
    
//    NSLog(@"The search text is %@", searchBar.text);
//    
//    if (![searchBar.text isEqualToString:@"Jordan"]) {
//        for (int i = 0; i < 3; i++) {
//            SearchResult *searchResult = [[SearchResult alloc] init];
//            searchResult.name = [NSString stringWithFormat:@"Fake result %d for", i];
//            searchResult.artistName = searchBar.text;
//            [_searchResults addObject:searchResult];
//            
//        }
//    }
    
    
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_searchResults count] == 0) {
        return nil;
    } else {
        return indexPath;
    }
}
@end
