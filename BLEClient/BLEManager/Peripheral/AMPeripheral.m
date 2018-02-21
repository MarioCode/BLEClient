//
//  AMPeripheral.m
//  BLEClient
//
//  Created by Anton Makarov on 20.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "AMPeripheral.h"
#import "AMCharacteristics.h"


@implementation AMPeripheral

#pragma mark -
#pragma mark Init

- (instancetype)init {
  return [self initWithCBPeripheral:nil];
}

+ (instancetype)peripheralWithCBPeripheral:(CBPeripheral *)cbPeripheral {
  return [[self alloc] initWithCBPeripheral:cbPeripheral];
}

- (instancetype)initWithCBPeripheral:(CBPeripheral *)cbPeripheral {
  self = [super init];
  
  if (self != nil) {
    if (cbPeripheral != nil) {
      _CBPeripheral = cbPeripheral;
      _CBPeripheral.delegate = self;
      
      _peripheryInfo = [PeripheryInfo sharedInstance];
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

- (void)sendRequestData:(NSData *)requestData
{
  if ([self isConnected]) {
    //VYDataTransferService *service = self.services[self.dataTransferServiceUUID];
    //[service sendRequestData:requestData completion:handler];
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
  [self.CBPeripheral discoverServices: self.peripheryInfo.services];
}

- (void)didFailToConnectWithError:(NSError *)error {
  NSLog(@"Error: Fail To Connect");
}

- (void)didDisconnectWithError:(NSError *)error {
  NSLog(@"Error: Peripheral Disconnected");
}

- (void)observeAllInfoForPeripheral {
  for (CBUUID* key in self.services) {
    id value = [self.services objectForKey:key];
    //[self.CBPeripheral discoverCharacteristics:_peripheryInfo.characteristics forService:value];

    // do stuff
  }
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
    self.services[cbService.UUID] = cbService;
    [self.CBPeripheral discoverCharacteristics:nil forService:self.services[cbService.UUID]];
  }
  [self observeAllInfoForPeripheral];

}

- (void)peripheral:(CBPeripheral *)cbPeripheral didDiscoverCharacteristicsForService:(CBService *)cbService error:(NSError *)error
{
  NSLog(@"Info: CBPeripheral did discover characteristics for service: %@; Error: %@", cbService, error);
  
  AMService *service = [[AMService alloc] initWithCBService:self.services[cbService.UUID]];
  [service discoverCharacteristics:_peripheryInfo.characteristics];
}

- (void)peripheral:(CBPeripheral *)cbPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)cbCharacteristic error:(NSError *)error {
  NSLog(@"Error: CBPeripheral did update value for characteristic: %@; Error: %@", cbCharacteristic, error);
  
  AMService *service = self.services[cbCharacteristic.service.UUID];
  AMCharacteristics *characteristic = service.characteristics[cbCharacteristic.UUID];
  [characteristic didUpdateValueWithError:error];
}

- (void)peripheral:(CBPeripheral *)cbPeripheral didWriteValueForCharacteristic:(CBCharacteristic *)cbCharacteristic error:(NSError *)error {
  NSLog(@"Info: CBPeripheral did write value for characteristic: %@; Error: %@", cbCharacteristic, error);
  
  AMService *service = self.services[cbCharacteristic.service.UUID];
  AMCharacteristics *characteristic = service.characteristics[cbCharacteristic.UUID];
  [characteristic didWriteValueWithError:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)cbCharacteristic error:(NSError *)error {
  NSLog(@"Info: CBPeripheral did update notification state for characteristic: %@; Error: %@", cbCharacteristic, error);
  
  AMService *service = self.services[cbCharacteristic.service.UUID];
  AMCharacteristics *characteristic = service.characteristics[cbCharacteristic.UUID];
  [characteristic didUpdateNotificationStateWithError:error];
}


#pragma mark -
#pragma mark Helper

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if (context == (__bridge void *)([self class]))
  {
    if (object == self.CBPeripheral)
    {
      if ([keyPath isEqualToString:@"services"])
      {
        if ([object valueForKeyPath:keyPath] == nil)
        {
          [self.services removeAllObjects];
        }
      }
    }
  }
  else
  {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

@end
