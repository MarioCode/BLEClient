//
//  MainViewController.m
//  BLEClient
//
//  Created by Anton Makarov on 05.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "MainViewController.h"


@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [BLECentralManager sharedManager];
  [[LocationManager sharedManager] startTracking];
  
  [NSTimer scheduledTimerWithTimeInterval:3.0
                                   target:self
                                 selector:@selector(stop)
                                 userInfo:nil
                                  repeats:NO];
}

- (void)stop {
//  [[BLECentralManager sharedManager] stopScanForPeripherals];
}


#pragma mark -
#pragma mark Button Action


- (IBAction)readData:(id)sender {
}


- (IBAction)writeData:(id)sender {
}


- (IBAction)getAllInfo:(id)sender {
  [[BLECentralManager sharedManager] getAllInfo];
}


@end
