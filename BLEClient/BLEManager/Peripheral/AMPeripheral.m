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
      _udpPort = arc4random_uniform(65535 - 49152) + 49152;
    }
    else {
      self = nil;
    }
  }
  
  return self;
}


#pragma mark -
#pragma mark Methods


- (void)didUpdateDeviceLocation:(NSString *)coordinates {
  for (CBUUID *  key in self.services) {
    AMService *value = [self.services objectForKey:key];
    
    for (CBUUID *key in value.characteristics) {
      AMCharacteristics *charVal = [value.characteristics objectForKey:key];
      if (charVal.isWrite)
        [charVal writeValue:coordinates];
    }
  }
}


- (void)sendRequestData:(NSData *)requestData {

  if ([self isConnected]) {
    NSLog(@"Get data for sending - %@", requestData);
  }
}


- (BOOL)isConnected {
  return self.CBPeripheral.state == CBPeripheralStateConnected;
}


#pragma mark -
#pragma mark Handling CBCentralManager Callbacks


- (void)didConnect {
  
  NSLog(@"Info: Connected to %@", self.CBPeripheral);
  [self discoverServices];
}

- (void)discoverServices {
  [self.CBPeripheral discoverServices:[PeripheryInfo sharedInstance].services];
}

- (void)didFailToConnectWithError:(NSError *)error {
  NSLog(@"Error: Fail To Connect");
}

- (void)didDisconnectWithError:(NSError *)error {
  NSLog(@"Error: Peripheral Disconnected");
}


#pragma mark -
#pragma mark <CBPeripheralDelegate>


- (void)peripheral:(CBPeripheral *)cbPripheral didModifyServices:(NSArray *)invalidatedCBServices {
  NSLog(@"Info: CBPeripheral did modify services: %@", invalidatedCBServices);
  
  NSArray *serviceUUIDs = [invalidatedCBServices valueForKey:@"UUID"];
  [self.services removeObjectsForKeys:serviceUUIDs];
}

- (void)peripheral:(CBPeripheral *)cbPeripheral didDiscoverServices:(NSError *)error {
  
  if (error != nil) {
    NSLog(@"Error: CBPeripheral did discover service with error: %@", error);
    return;
  }
  
  NSLog(@"Info: CBPeripheral did discover services");
    
  for (CBService *cbService in cbPeripheral.services) {
    NSLog(@"Service: %@", cbService);
    AMService *amService = [[AMService alloc] initWith:cbService];
    
    self.services[cbService.UUID] = amService;
    [self.CBPeripheral discoverCharacteristics:[PeripheryInfo sharedInstance].characteristics forService:cbService];
  }
}


- (void)peripheral:(CBPeripheral *)cbPeripheral didDiscoverCharacteristicsForService:(CBService *)cbService error:(NSError *)error {
  NSLog(@"Info: CBPeripheral did discover characteristics for service: %@; Error: %@", cbService, error);
  [self.services[cbService.UUID] discoverCharacteristics];
}


// Recieve data from device
- (void)peripheral:(CBPeripheral *)cbPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)cbCharacteristic error:(NSError *)error {
  NSLog(@"Info: CBPeripheral did update value for characteristic: %@; Error: %@", cbCharacteristic, error);
  
  AMService *service = self.services[cbCharacteristic.service.UUID];
  AMCharacteristics *characteristic = service.characteristics[cbCharacteristic.UUID];
  
  NSString *stringFromData = [[NSString alloc] initWithData:cbCharacteristic.value encoding:NSUTF8StringEncoding];
  characteristic.charValue = stringFromData;
  
 // [self.udpManager didSendDataWithValue:cbCharacteristic.value];
}


@end
