//
//  LocationManager.h
//  BLEClient
//
//  Created by Anton Makarov on 27.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <NotificationCenter/NotificationCenter.h>

@interface LocationManager : NSObject

@property (nonatomic, strong) CLLocation *currentLocation;

+ (LocationManager*)sharedManager;
- (void)startTracking;
- (void)stopTracking;
- (void)allowsBackgroundLocationUpdates:(BOOL)allow;

@end
