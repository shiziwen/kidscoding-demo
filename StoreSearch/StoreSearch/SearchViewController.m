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
#import <AFNetworking/AFNetworking.h>
#import "DetailViewController.h"
#import "LandscapeViewController.h"
#import "Search.h"

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NothingFoundCellIdentifier = @"NothingFoundCell";
static NSString * const LoadingCellIdentifier = @"LoadingCell";

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@end

@implementation SearchViewController {
//    NSMutableArray *_searchResults;
//    BOOL _isLoading;
//    NSOperationQueue *_queue;
    
    Search *_search;
    
    LandscapeViewController *_landscapeViewController;
    UIStatusBarStyle _statusBarStyle;
    DetailViewController *_detailViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        _queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.contentInset = UIEdgeInsetsMake(108, 0, 0, 0);
    self.tableView.rowHeight = 80;
    
    UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    
    cellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
    
    cellNib = [UINib nibWithNibName:LoadingCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:LoadingCellIdentifier];
    
    [self.searchBar becomeFirstResponder];
    
    _statusBarStyle = UIStatusBarStyleDefault;
    NSLog(@"status bar style is %ld", (long)_statusBarStyle);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UITableViewDataSource
//
//- (NSString *)kindForDisplay:(NSString *)kind {
//    if ([kind isEqualToString:@"album"]) {
//        return @"Album";
//    } else if ([kind isEqualToString:@"audiobook"]) {
//        return @"Audio Book";
//    } else if ([kind isEqualToString:@"book"]) {
//        return @"Book";
//    } else if ([kind isEqualToString:@"ebook"]) {
//        return @"E-Book";
//    } else if ([kind isEqualToString:@"feature-movie"]) {
//        return @"Movie";
//    } else if ([kind isEqualToString:@"music-video"]) {
//        return @"Music Video";
//    } else if ([kind isEqualToString:@"podcast"]) {
//        return @"Podcast";
//    } else if ([kind isEqualToString:@"software"]) {
//        return @"App";
//    } else if ([kind isEqualToString:@"song"]) {
//        return @"Song";
//    } else if ([kind isEqualToString:@"tv-episode"]) {
//        return @"TV Episode";
//    } else {
//        return kind;
//    }
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_search.isLoading) {
        return 1;
    } else if (_search.searchResults == nil) {
        return 0;
    } else if ([_search.searchResults count] == 0) {
        return 1;
    } else {
        return [_search.searchResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier = @"SearchResultCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//    }
    
    if (_search.isLoading) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier forIndexPath:indexPath];
        
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:100];
        [spinner startAnimating];
        
        return cell;
    }
    if ([_search.searchResults count] == 0) {
        return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier forIndexPath:indexPath];
    } else {
        SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier];
        
        SearchResult *searchResult = _search.searchResults[indexPath.row];
        
        [cell configureForSearchResult:searchResult];
        
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


- (NSString *)performStoreRequestWithUrl:(NSURL *)url {
    NSError *error;
    NSString *resultString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (resultString == nil) {
        NSLog(@"Fetch error is %@", error);
        return nil;
    }
    
    return resultString;
}


- (void)performSearch {
    _search = [[Search alloc] init];
    NSLog(@"allc %@", _search);
    
    [_search performSearchForText:self.searchBar.text
                         category:self.segmentControl.selectedSegmentIndex
                       completion:^(BOOL success){
                           if (!success) {
                               [self showNetworkError];
                           }
                           
                           [_landscapeViewController searchResultsReceived];
                           [self.tableView reloadData];

        
    }];
    
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
    
//    if ([self.searchBar.text length] > 0) {
//        [self.searchBar resignFirstResponder];
//        
//        [_queue cancelAllOperations];
//        
//        _isLoading = YES;
//        [self.tableView reloadData];
//        
//        _searchResults = [NSMutableArray arrayWithCapacity:10];
//        
//        NSURL *url = [self urlWithSearchText:self.searchBar.text category:self.segmentControl.selectedSegmentIndex];
//        NSURLRequest *request = [NSURLRequest requestWithURL:url];
//        
//        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//        operation.responseSerializer = [AFJSONResponseSerializer serializer];
//        
//        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id reponseObject) {
//            NSLog(@"Succuess %@", reponseObject);
//            
//            [self parseDictionary:reponseObject];
//            [_searchResults sortUsingSelector:@selector(compareName:)];
//            
//            _isLoading = NO;
//            [self.tableView reloadData];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            if (operation.isCancelled) {
//                return;
//            }
//            
//            NSLog(@"Failure %@", error);
//            
//            [self showNetworkError];
//            
//            _isLoading = NO;
//            [self.tableView reloadData];
//        }];
//        
//        [_queue addOperation:operation];
//        
//    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self performSearch];
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DetailViewController *controller = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    controller.searchResult = _search.searchResults[indexPath.row];
    
    [controller presentInParentViewController:self];
    
    _detailViewController = controller;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_search.searchResults count] == 0 || _search.isLoading) {
        return nil;
    } else {
        return indexPath;
    }
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    NSLog(@"segment changed: %ld", (long)sender.selectedSegmentIndex);
    
    if (_search != nil) {
        [self performSearch];
    }
}

// When a view controller is about to be flipped over, it will let you know with this method.
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        [self hideLandscapeViewWithDuration:duration];
    } else {
        [self showLandscapeViewWithDuration:duration];
    }
}

- (void)showLandscapeViewWithDuration:(NSTimeInterval)duration {
    NSLog(@"showLandscapeViewWithDuration");
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    if (_landscapeViewController == nil) {
        _landscapeViewController = [[LandscapeViewController alloc] initWithNibName:@"LandscapeViewController" bundle:nil];
        
        _landscapeViewController.search = _search;
        
        _landscapeViewController.view.frame = self.view.bounds;
        _landscapeViewController.view.alpha = 0.0f;
        
        [self.view addSubview:_landscapeViewController.view];
        [self addChildViewController:_landscapeViewController];
        
        [UIView animateWithDuration:duration animations:^{
            _landscapeViewController.view.alpha = 1.0f;
            
            _statusBarStyle = UIStatusBarStyleLightContent;
            [self setNeedsStatusBarAppearanceUpdate];
            NSLog(@"status bar style is %ld", (long)_statusBarStyle);
        } completion:^(BOOL finished){
            [_landscapeViewController didMoveToParentViewController:self];
        }];
        
        [self.searchBar resignFirstResponder];
        [_detailViewController dismissFromParentViewControllerWithAnimationType:DetailViewControllerAnimationTypeSlide];
    }
}

- (void)hideLandscapeViewWithDuration:(NSTimeInterval)duration {
    NSLog(@"hideLandscapeViewWithDuration");
    
    if (_landscapeViewController != nil) {
        [_landscapeViewController willMoveToParentViewController:nil];
        
        [UIView animateWithDuration:duration animations:^{
            _landscapeViewController.view.alpha = 0.0f;
            
            _statusBarStyle = UIStatusBarStyleDefault;
//            _statusBarStyle = UIStatusBarStyleLightContent;
            [self setNeedsStatusBarAppearanceUpdate];
            NSLog(@"status bar style is %ld", (long)_statusBarStyle);
        } completion:^(BOOL finished){
            [_landscapeViewController.view removeFromSuperview];
            [_landscapeViewController removeFromParentViewController];
            
            _landscapeViewController = nil;
        }];
    }
}

// This method is called by UIKit to determine what color to make the status bar.
- (UIStatusBarStyle)preferredStatusBarStyle {
    NSLog(@"get status bar style");
    return _statusBarStyle;
}

@end
