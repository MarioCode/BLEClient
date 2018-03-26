//
//  LocationManager.m
//  BLEClient
//
//  Created by Anton Makarov on 27.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager () <CLLocationManagerDelegate> {
  CLLocation *lastSendLocation;
}

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic) BOOL deferringUpdates;
@end

@implementation LocationManager

+ (LocationManager*)sharedManager
{
  static LocationManager* sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [[LocationManager alloc] init];
    sharedInstance.locationManager = [[CLLocationManager alloc] init];
    sharedInstance.locationManager.delegate = sharedInstance;
    sharedInstance.locationManager.distanceFilter = kCLDistanceFilterNone;
    sharedInstance.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    sharedInstance.locationManager.allowsBackgroundLocationUpdates = true;
    [sharedInstance.locationManager requestAlwaysAuthorization];
  });
  
  return sharedInstance;
}

- (void)allowsBackgroundLocationUpdates:(BOOL)allow {
  self.locationManager.allowsBackgroundLocationUpdates = allow;
}


- (void)startTracking {
  [self.locationManager startUpdatingLocation];
}


- (void)stopTracking {
  [self.locationManager stopUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  if (!self.deferringUpdates) {
    if([CLLocationManager deferredLocationUpdatesAvailable]){
      [_locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:CLTimeIntervalMax];
      self.deferringUpdates = YES;
    }
  }
  
  self.currentLocation = locations.lastObject;
  [[NSNotificationCenter defaultCenter] postNotificationName:@"GetLocationNotification" object:locations];
}



@end

