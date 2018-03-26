//
//  AMCharacteristics.m
//  BLEClient
//
//  Created by Anton Makarov on 20.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "AMCharacteristics.h"


@implementation AMCharacteristics

#pragma mark -
#pragma mark Object Init

- (instancetype)init {
  return [self initWith:nil];
}


- (instancetype)initWith:(CBCharacteristic *)cbCharacteristic {
  self = [super init];
  
  if (self != nil) {
    if (cbCharacteristic != nil) {
      _CBCharacteristic = cbCharacteristic;
        
        if ([cbCharacteristic.UUID.UUIDString isEqualToString:@"0000FF01-0000-1000-8000-00805F9B34FB"]) {
          self.characteristicType = READ_UDP;
          [self.CBCharacteristic.service.peripheral setNotifyValue:true forCharacteristic:self.CBCharacteristic];
        } else if ([cbCharacteristic.UUID.UUIDString isEqualToString:@"0000FF02-0000-1000-8000-00805F9B34FB"]) {
            self.characteristicType = WRITE_UDP;
        } else if ([cbCharacteristic.UUID.UUIDString isEqualToString:@"0000FF03-0000-1000-8000-00805F9B34FB"]) {
            self.characteristicType = LOCATION;
        }
    } else
        self = nil;
  }
  
  return self;
}


#pragma mark -
#pragma mark Handheld Methods


- (void)writeValue:(NSData *) data {
    [self.CBCharacteristic.service.peripheral writeValue:data forCharacteristic:self.CBCharacteristic type:CBCharacteristicWriteWithResponse];
}


- (void)setNotifyValue:(BOOL)enabled  {
 // [self.CBCharacteristic.service.peripheral setNotifyValue:enabled forCharacteristic:self.CBCharacteristic];
}


@end
