//
//  MapViewController.m
//  MyLocations
//
//  Created by mac on 16/1/21.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import "MapViewController.h"
#import "Location.h"
#import "LocationDetailViewController.h"

@interface MapViewController () <MKMapViewDelegate, UINavigationBarDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController {
    NSArray *_locations;
}

- (IBAction)showUser {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

- (void)updateLocations {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (foundObjects == nil) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    
    if (_locations != nil) {
        [self.mapView removeAnnotations:_locations];
    }
    
    _locations = foundObjects;
    [self.mapView addAnnotations:_locations];
    
}

- (IBAction)showLocations {
    MKCoordinateRegion region = [self regionForAnnotations:_locations];
    [self.mapView setRegion:region animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    
    // Do any additional setup after loading the view.
    [self updateLocations];
    
    if ([_locations count] > 0) {
        [self showLocations];
    }
    
//    self.mapView.delegate = self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidChange:)
                                                     name:NSManagedObjectContextObjectsDidChangeNotification
                                                   object:self.managedObjectContext];
        
    }
    return self;
}

- (void)contextDidChange:(NSNotification *)notification {
//    notification.userInfo.
    NSLog(@"contextDidChange");
    if ([self isViewLoaded]) {
//        [self updateLocations];
        NSMutableArray *objectsToReload = [[NSMutableArray alloc] init];
        [objectsToReload addObjectsFromArray:_locations];
        
        if ([notification.userInfo valueForKey:NSInsertedObjectsKey]) {
            NSArray *insert = [NSArray arrayWithArray:[[notification.userInfo valueForKey:
                                                        NSInsertedObjectsKey] allObjects]];
            [self.mapView addAnnotations:insert];
            [objectsToReload addObjectsFromArray:insert];
        } else if ([notification.userInfo valueForKey:NSDeletedObjectsKey]) {
            NSArray *delete = [NSArray arrayWithArray:[[notification.userInfo valueForKey:
                                                        NSDeletedObjectsKey] allObjects]];
            [self.mapView removeAnnotations:delete];
            [objectsToReload removeObjectsInArray:delete];
        } else if ([notification.userInfo valueForKey:NSUpdatedObjectsKey]) {
            NSArray *update = [NSArray arrayWithArray:[[notification.userInfo valueForKey:
                                                        NSUpdatedObjectsKey] allObjects]];
            [self.mapView removeAnnotations:update];
            [self.mapView addAnnotations:update];
            [objectsToReload removeObjectsInArray:update];
            [objectsToReload addObjectsFromArray:update];
        }
        _locations = (NSArray *)objectsToReload;
        [self showLocations];
    }
}

- (MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations {
    MKCoordinateRegion region;
    NSLog(@"annotations count is %ld", [annotations count]);
    
    if ([annotations count] == 0) {
        region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
    } else if ([annotations count] == 1) {
        id <MKAnnotation> annotation = [annotations lastObject];
        region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000);
    } else {
        CLLocationCoordinate2D topLeftCoord;
        topLeftCoord.latitude = -90;
        topLeftCoord.longitude = 180;
        
        CLLocationCoordinate2D bottomRightCoord;
        bottomRightCoord.latitude = 90;
        bottomRightCoord.longitude = -180;
        
        for (id <MKAnnotation> annotation in annotations) {
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        }
        
        const double extraSpace = 1.1;
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2.0;
        region.center.longitude = topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2.0;
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace;
        region.span.longitudeDelta = fabs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace;
    }
    
    return [self.mapView regionThatFits:region];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    NSLog(@"MKMapViewDelegate");
    
    if ([annotation isKindOfClass:[Location class]]) {
        static NSString *identifier = @"Location";
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.animatesDrop = NO;
            annotationView.pinColor = MKPinAnnotationColorGreen;
            annotationView.tintColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(showLocationDetails:) forControlEvents:UIControlEventTouchUpInside];
            annotationView.rightCalloutAccessoryView = rightButton;
        } else {
            annotationView.annotation = annotation;
        }
        
        UIButton *button = (UIButton *)annotationView.rightCalloutAccessoryView;
        button.tag = [_locations indexOfObject:(Location *)annotation];
        
        return annotationView;
    }
    
    return nil;
}

- (void)showLocationDetails:(UIButton *)button {
    [self performSegueWithIdentifier:@"EditLocation" sender:button];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditLocation"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        LocationDetailViewController *controller = (LocationDetailViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        
        UIButton *button = (UIButton *)sender;
        Location *location = _locations[button.tag];
        controller.locationToEdit = location;
        
    }
}

#pragma mark - UINavigationBarDelegate

- (UIBarPosition) positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
