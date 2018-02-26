//
//  MainViewController.m
//  BLEClient
//
//  Created by Anton Makarov on 05.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "MainViewController.h"
#import "BLECentralManager.h"
#import "AMPeripheral.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIButton *scanOnceButton;
@property (weak, nonatomic) IBOutlet UIButton *writeButton;
@property (weak, nonatomic) IBOutlet UILabel *genStringLabel;

@property (strong, nonatomic) UDPManager *udpSocket;
@property (strong, nonatomic) BLECentralManager *centralManager;

@end


@implementation MainViewController

BOOL isSend = false;
BOOL isAllDevices = false;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _centralManager = [BLECentralManager sharedManager];
  _udpSocket = [UDPManager shareUDPSocket];
  
  [NSTimer scheduledTimerWithTimeInterval:3.0
                                   target:self
                                 selector:@selector(stop)
                                 userInfo:nil
                                  repeats:NO];
}

- (void)stop {
  [_centralManager stopScanForPeripherals];
}


#pragma mark -
#pragma mark Button Action


- (IBAction)scanBluetoothDevices:(id)sender {
  _scanOnceButton.enabled = false;
}


- (IBAction)readData:(id)sender {
}


- (IBAction)writeData:(id)sender {
  
  NSString *str = [self randomStringWithLength:7];
  _genStringLabel.text = str;
  
  [_udpSocket updateConnectToPort:arc4random_uniform(100)+60000];
 // [_udpSocket didSendDataWithValue:nil];
}


- (IBAction)getAllInfo:(id)sender {
  [_centralManager getPeripheralInfo];
}


#pragma mark -
#pragma mark Helpers


// Generate random string
-(NSString *) randomStringWithLength: (int) len {
  
  NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
  
  for (int i = 0; i < len; i++) {
    [randomString appendFormat: @"%C", [letters characterAtIndex:(NSUInteger)arc4random_uniform((u_int32_t)[letters length])]];
  }
  
  return randomString;
}


#pragma mark -
#pragma mark Delegate Methods



// Stop scanning
- (void)stopScan {
  _scanOnceButton.enabled = true;
}

// **************************************** //

@end
