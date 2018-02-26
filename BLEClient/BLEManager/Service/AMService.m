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

- (void)discoverCharacteristics {
  
  for (CBCharacteristic *characteristic in self.Service.characteristics) {
    
    AMCharacteristics *amChar = [AMCharacteristics characteristicWithCBCharacteristic:characteristic];
    [amChar setNotifyValue:(characteristic.properties & CBCharacteristicPropertyNotify)];
    
    self.characteristics[characteristic.UUID] = amChar;
  }
}

@end
