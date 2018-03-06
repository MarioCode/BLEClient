//
//  AMPeripheral.m
//  BLEClient
//
//  Created by Anton Makarov on 20.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "AMPeripheral.h"
#import "AMCharacteristics.h"
#import "UDPManager.h"

@implementation AMPeripheral

#pragma mark -
#pragma mark Init

- (instancetype)init {
  return [self initWith:nil];
}


- (instancetype)initWith:(CBPeripheral *)cbPeripheral {
  self = [super init];
  
  if (self != nil) {
    if (cbPeripheral != nil) {
      _CBPeripheral = cbPeripheral;
      _CBPeripheral.delegate = self;      
      _services = [NSMutableDictionary dictionary];
    }
    else {
      self = nil;
    }
  }
  
  return self;
}


#pragma mark -
#pragma mark Methods


// Update the coordinates for the device. Write to the characteristic.
- (void)updateDeviceLocation:(NSString *)coordinates {
  
  if (!self.isCanUpdateCoordinate) {
    return;
  }
  
  for (CBUUID *key in self.services) {
    AMService *value = [self.services objectForKey:key];
    
    for (CBUUID *key in value.characteristics) {
      AMCharacteristics *charVal = [value.characteristics objectForKey:key];
        [charVal writeValue:coordinates];
    }
  }
}


//  Recieve data from UDP
- (void)receivingDataFromUDP:(NSData *)recieveData {

  if ([self isConnected]) {
    [self writeRecieveDataToCharacheristic:recieveData];
  }
}


// And send to peripheral's characteristic
- (void)writeRecieveDataToCharacheristic:(NSData *)requestData {
  
  [[Logger sharedManager] sendLogToMainVC:@"Info: UDP -> BLE> Write recieve data to characheristic"];

  for (CBUUID * key in self.services) {
    AMService *value = [self.services objectForKey:key];
    
    for (CBUUID *key2 in value.characteristics) {
      
      AMCharacteristics *charVal = [value.characteristics objectForKey:key2];
        [charVal writeValue:requestData];
    }
  }
}


// Checking peripheral connecting
- (BOOL)isConnected {
  return self.CBPeripheral.state == CBPeripheralStateConnected;
}


// Trying finding services for peripheral
- (void)didConnectAndDiscoverServices {
  
  NSString *log = [NSString stringWithFormat:@"Info: Connected to %@", self.CBPeripheral];
  [[Logger sharedManager] sendLogToMainVC:log];
  
  [self.CBPeripheral discoverServices:[PeripheryInfo sharedInstance].services];
}


// Custom setter for property
- (void) setForCanUpdateCoordinate:(NSInteger)RSSI {
  if (RSSI < -75) {
    self.isCanUpdateCoordinate = false;
  } else {
    self.isCanUpdateCoordinate = true;
  }
}


#pragma mark -
#pragma mark <CBPeripheralDelegate>


// - didDiscoverServices
- (void)peripheral:(CBPeripheral *)cbPeripheral didDiscoverServices:(NSError *)error {
  
  if (error != nil) {
    NSString *log = [NSString stringWithFormat:@"ErrorCB: CBPeripheral did discover service with error: %@", error];
    [[Logger sharedManager] sendLogToMainVC:log];
    return;
  }
  
  [[Logger sharedManager] sendLogToMainVC:@"Info: CBPeripheral did discover services"];
  
  for (CBService *cbService in cbPeripheral.services) {
    NSString *log = [NSString stringWithFormat:@"Service: %@", cbService];
    [[Logger sharedManager] sendLogToMainVC:log];
    
    AMService *amService = [[AMService alloc] initWith:cbService];
    
    self.services[cbService.UUID] = amService;
    [self.CBPeripheral discoverCharacteristics:[PeripheryInfo sharedInstance].characteristics forService:cbService];
  }
}


// Discover characteristics for services
- (void)peripheral:(CBPeripheral *)cbPeripheral didDiscoverCharacteristicsForService:(CBService *)cbService error:(NSError *)error {
  
  if (error != nil) {
    NSLog(@"Error: CBPeripheral did discover characteristics with error: %@", error);
    return;
  }
  
  NSString *log = [NSString stringWithFormat:@"Info: CBPeripheral did discover characteristics for service: %@; Error: %@", cbService, error];
  [[Logger sharedManager] sendLogToMainVC:log];
  
  [self.services[cbService.UUID] discoverCharacteristics];
}


// Recieve data from device
- (void)peripheral:(CBPeripheral *)cbPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)cbCharacteristic error:(NSError *)error {
  
  if (error != nil) {
    NSLog(@"Error: CBPeripheral did update value for characteristic with error: %@", error);
    return;
  }
  
  NSString *log = [NSString stringWithFormat:@"Info: CBPeripheral did update value for characteristic: %@; Error: %@", cbCharacteristic, error];
  [[Logger sharedManager] sendLogToMainVC:log];
  
  [self.udpManager didSendDataWithValue:cbCharacteristic.value];
}



// - didModifyServices
- (void)peripheral:(CBPeripheral *)cbPripheral didModifyServices:(NSArray *)invalidatedCBServices {
  
  NSString *log = [NSString stringWithFormat:@"Info: CBPeripheral did modify services: %@", invalidatedCBServices];
  [[Logger sharedManager] sendLogToMainVC:log];
    
  NSArray *serviceUUIDs = [invalidatedCBServices valueForKey:@"UUID"];
  [self.services removeObjectsForKeys:serviceUUIDs];
}

@end
