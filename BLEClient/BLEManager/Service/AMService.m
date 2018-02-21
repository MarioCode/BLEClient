//
//  AMService.m
//  BLEClient
//
//  Created by Anton Makarov on 20.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "AMService.h"
#import "AMCharacteristics.h"

@implementation AMService

#pragma mark -
#pragma mark Init Services

- (instancetype)init {
  return [self initWithCBService:nil];
}

+ (instancetype)serviceWithCBService:(CBService *)cbService {
  return [[self alloc] initWithCBService:cbService];
}

- (instancetype)initWithCBService:(CBService *)cbService {
  self = [super init];
  
  if (self != nil) {
    if (cbService != nil) {
      _Service = cbService;
      _peripheryInfo = [PeripheryInfo sharedInstance];

      _characteristics = [NSMutableDictionary dictionary];
    }
    else {
      self = nil;
    }
  }
  
  return self;
}

#pragma mark -
#pragma mark Methods

- (void)discoverCharacteristics:(NSArray *)characteristicUUIDs {
  
  if (self.discoverCharacteristicsInProgress) {
    NSLog(@"Another discovery characteristics task is in progress.");
    return;
  }
  
  for (CBCharacteristic *characteristic in _Service.characteristics)
    self.characteristics[characteristic.UUID] = characteristic;
  
  
  self.discoverCharacteristicsInProgress = YES;
  //[self.Service.peripheral discoverCharacteristics: self.peripheryInfo.characteristics forService:self.Service];
}

- (void)didDiscoverCharacteristicsWithError:(NSError *)error {
  
  if (error == nil) {
    for (CBCharacteristic *cbChar in self.Service.characteristics) {
      AMCharacteristics *characteristic = self.characteristics[cbChar.UUID];
      
      if (characteristic)
        self.characteristics[characteristic.CBCharacteristic.UUID] = characteristic;
    }
  }
}

@end
