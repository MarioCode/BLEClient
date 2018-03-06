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
    }
    else
      self = nil;
  }
  
  return self;
}


#pragma mark -
#pragma mark Handheld Methods


- (void)readValueForCharacteristic {
  if (self.CBCharacteristic.properties & CBCharacteristicPropertyRead) {
    [self.CBCharacteristic.service.peripheral readValueForCharacteristic:self.CBCharacteristic];
  }
}


- (void)readValueForDescriptor {

}


- (void)writeValue:(NSData *) data {
    [self.CBCharacteristic.service.peripheral writeValue:data forCharacteristic:self.CBCharacteristic type:CBCharacteristicWriteWithResponse];
}


- (void)setNotifyValue:(BOOL)enabled  {
  [self.CBCharacteristic.service.peripheral setNotifyValue:enabled forCharacteristic:self.CBCharacteristic];
}


@end
