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
  return [self initWith:nil];
}

- (instancetype)initWith:(CBService *)cbService {
  self = [super init];
  
  if (self != nil) {
    if (cbService != nil) {
      _Service = cbService;
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


// Search for a service characteristic
- (void)discoverCharacteristics {
  
  for (CBCharacteristic *characteristic in self.Service.characteristics) {
    
    AMCharacteristics *amChar = [[AMCharacteristics alloc] initWith:characteristic];
    [amChar setNotifyValue:(characteristic.properties & CBCharacteristicPropertyNotify)];
    [amChar readValue];
    
    if (characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) {
      amChar.isWrite = true;
    }

    NSLog(@"Info Char - %@", amChar.CBCharacteristic);
    self.characteristics[characteristic.UUID] = amChar;
  }
}

@end
