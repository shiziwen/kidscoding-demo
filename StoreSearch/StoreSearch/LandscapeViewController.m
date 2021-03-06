//
//  LandscapeViewController.m
//  StoreSearch
//
//  Created by mac on 16/2/19.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import <AFNetworking/UIButton+AFNetworking.h>
#import "LandscapeViewController.h"
#import "SearchResult.h"
#import "Search.h"
#import "DetailViewController.h"

@interface LandscapeViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControll;

@end

@implementation LandscapeViewController {
    BOOL _firstTime;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        _firstTime = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LandscapeBackground"]];
    
    self.pageControll.numberOfPages = 0;

}

- (void)showSpinner {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    spinner.center = CGPointMake(CGRectGetMidX(self.scrollView.bounds) + 0.5f, CGRectGetMidY(self.scrollView.bounds) + 0.5f);
    spinner.tag = 1000;
    [self.view addSubview:spinner];
    [spinner startAnimating];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (_firstTime) {
        _firstTime = NO;
        
        if (self.search.isLoading) {
            [self showSpinner];
            
        } else if ([self.search.searchResults count] == 0) {
            [self showNothingFoundLabel];
        }
        else {
            [self tileButtons];
        }        
    }
}

- (void)tileButtons {
    int columnsPerPage = 5;
    CGFloat itemWidth = 96.0f;
    CGFloat x = 0.0f;
    CGFloat extraSpace = 0.0f;
    
    CGFloat scrollViewWidth = self.scrollView.bounds.size.width;
    NSLog(@"scrollViewWidth is %f", scrollViewWidth);
    if (scrollViewWidth > 480.0f) {
        columnsPerPage = 6;
        itemWidth = 94.0f;
        x = 2.0f;
        extraSpace = 4.0f;
    }
    
    const CGFloat itemHeight = 88.0f;
    const CGFloat buttonWidth = 82.0f;
    const CGFloat buttonHeight = 82.0f;
    const CGFloat marginHorz = (itemWidth - buttonWidth) / 2.0f;
    const CGFloat marginVert = (itemHeight - buttonHeight) / 2.0f;
    
    int index = 0;
    int row = 0;
    int column = 0;
    
    for (SearchResult *searchResult in self.search.searchResults) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [button setBackgroundImage:[UIImage imageNamed:@"LandscapeButton"] forState:UIControlStateNormal];
//        [button setTitle:[NSString stringWithFormat:@"%d", index] forState:UIControlStateNormal];
        
        button.frame = CGRectMake(x + marginHorz, 20.0f + row*itemHeight + marginVert, buttonWidth, buttonHeight);
        
        [self downloadImageForSearchResult:searchResult andPlaceOnButton:button];
        
        button.tag = 2000 + index;
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.scrollView addSubview:button];
        
        index++;
        row++;
        if (row == 3) {
            row = 0;
            column++;
            x += itemWidth;
            
            if (column == columnsPerPage) {
                column = 0;
                x += extraSpace;
            }
        }
    }
    
    int tilesPerPage = columnsPerPage * 3;
    int numPages = ceilf([self.search.searchResults count] / (float)tilesPerPage);
    
    self.scrollView.contentSize = CGSizeMake(numPages*scrollViewWidth, self.scrollView.bounds.size.height);
    
    NSLog(@"NUmbers of pages: %d", numPages);
    
    self.pageControll.numberOfPages = numPages;
    self.pageControll.currentPage = 0;
}

- (void)hideSpinner {
    [[self.view viewWithTag:1000] removeFromSuperview];
}

- (void)searchResultsReceived {
    [self hideSpinner];
    
    if ([self.search.searchResults count] == 0) {
        [self showNothingFoundLabel];
    } else {
        [self tileButtons];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    NSLog(@"dealloc %@", self);
    
    for (UIButton *button in self.scrollView.subviews) {
//        [button cancelImageRequestOperationForState:UIControlStateNormal];
    }
}

- (IBAction)pageChanged:(id)sender {
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width, 0);
                     }
                     completion:nil];
}

# pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat width = self.scrollView.bounds.size.width;
    int currentPage = (self.scrollView.contentOffset.x + width/2.0f) / width;
    self.pageControll.currentPage = currentPage;
}

- (void)downloadImageForSearchResult:(SearchResult *)searchResult andPlaceOnButton:(UIButton *)button {
    NSURL *url = [NSURL URLWithString:searchResult.artworkURL60];
//    NSLog(@"button image url is %@", url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    __weak UIButton *weakButton = button;
    
    
    [button setImageForState:UIControlStateNormal
              withURLRequest:request
            placeholderImage:[UIImage imageNamed:@"LandscapeButton"]
                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                         UIImage *unscaledImage = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:image.imageOrientation];
                         
                         [weakButton setImage:unscaledImage forState:UIControlStateNormal];
//                         [button setImage:image forState:UIControlStateNormal];
//                         NSLog(@"set iamge success");
                     }
                     failure:^(NSError *error) {
                         NSLog(@"error is %@", error);
                     }];

    
//    [button setImageForState:UIControlStateNormal withURL:url];
}

- (void)showNothingFoundLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = @"Nothing found";
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    
    [label sizeToFit];
    CGRect rect = label.frame;
    rect.size.width = ceilf(rect.size.width/2.0f) * 2.0f;
    rect.size.height = ceilf(rect.size.height/2.0f) * 2.0f;
    label.frame = rect;
    label.center = CGPointMake(CGRectGetMidX(self.scrollView.bounds), CGRectGetMidY(self.scrollView.bounds));
    
    [self.view addSubview:label];
}

- (void)buttonPressed:(UIButton *)sender {
    DetailViewController *controller = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    
    SearchResult *searchResult = self.search.searchResults[sender.tag - 2000];
    controller.searchResult = searchResult;
    
    [controller presentInParentViewController:self];
}
@end
