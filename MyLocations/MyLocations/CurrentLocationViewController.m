//
//  FirstViewController.m
//  MyLocations
//
//  Created by mac on 16/1/16.
//  Copyright © 2016年 shiziwen. All rights reserved.
//

#import "CurrentLocationViewController.h"

@interface CurrentLocationViewController ()

@end

@implementation CurrentLocationViewController {
    CLLocationManager *_locationManager;
    CLLocation *_location;
    BOOL _updatingLocation;
    NSError *_lastLocationError;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self updateLabels];
    [self configureGetButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getLocation:(id)sender {
    NSLog(@"touch getLocation");
    
    if (_updatingLocation) {
        [self stopLocationManager];
    } else {
        _location = nil;
        _lastLocationError = nil;
        [self startLocaionManager];
    }
    [self updateLabels];
    [self configureGetButton];
}

- (void)startLocaionManager {
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [_locationManager requestWhenInUseAuthorization];
    //    [_locationManager requestAlwaysAuthorization];
    [_locationManager startUpdatingLocation];
    
    _updatingLocation = YES;
}

- (void)stopLocationManager {
    if (_updatingLocation) {
        [_locationManager stopUpdatingLocation];
        _locationManager.delegate = nil;
        _updatingLocation = NO;
    }
}

# pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"get location error: %@", error);
    
    if (error.code == kCLErrorLocationUnknown) {
        return;
    }
    
    [self stopLocationManager];
    _lastLocationError = error;
//    _location = nil;
    
    [self updateLabels];
    [self configureGetButton];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"new Points: %@", newLocation);
    
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0) {
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    if (_location == nil || _location.horizontalAccuracy > newLocation.horizontalAccuracy) {
        _lastLocationError = nil;
        _location = newLocation;
        [self updateLabels];
        
        if (newLocation.horizontalAccuracy <= _location.horizontalAccuracy) {
            NSLog(@"Success get location");
            [self stopLocationManager];
            [self configureGetButton];
        }
    }
}

- (void)updateLabels {
    NSLog(@"updates");
    if (_location != nil) {
        self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", _location.coordinate.latitude];
        self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", _location.coordinate.latitude];
        self.tagButton.hidden = NO;
        self.messageLabel.text = @"";
    } else {
        self.latitudeLabel.text = @"";
        self.longitudeLabel.text = @"";
        self.addressLabel.text = @"";
        self.tagButton.hidden = YES;
        self.messageLabel.text = @"Press the Button to Start";
        
        NSString *statusMessage;
        if (_lastLocationError != nil) {
            if ([_lastLocationError.domain isEqualToString:kCLErrorDomain] &&
                _lastLocationError.code == kCLErrorDenied) {
                statusMessage = @"Sorry, user has denied the location service";
//                [_locationManager requestAlwaysAuthorization];
            } else {
                statusMessage = @"Sorry, get location error";
            }
        } else if (![CLLocationManager locationServicesEnabled]) {
            statusMessage = @"Sorry, user has denied the location service";
        } else if (_updatingLocation) {
            statusMessage = @"Searching location...";
        }
        self.messageLabel.text = statusMessage;
    }
}

- (void)configureGetButton {
    if (_updatingLocation) {
        [self.getButton setTitle:@"Stop get location" forState:UIControlStateNormal];
    } else {
        [self.getButton setTitle:@"Get current locaton" forState:UIControlStateNormal];
    }
}


@end
