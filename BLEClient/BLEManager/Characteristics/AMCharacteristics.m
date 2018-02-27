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
      
      NSString *stringFromData = [[NSString alloc] initWithData:cbCharacteristic.value encoding:NSUTF8StringEncoding];
      self.charValue = stringFromData;
    }
    else
      self = nil;
  }
  
  return self;
}

#pragma mark -
#pragma mark Methods

- (void)readValue {
  if (self.CBCharacteristic.properties & CBCharacteristicPropertyRead)
    [self.CBCharacteristic.service.peripheral readValueForCharacteristic:self.CBCharacteristic];
}

- (void)writeValue:(NSString *) value {
  if (self.isWrite) {
    [self.CBCharacteristic.service.peripheral writeValue:[value dataUsingEncoding:NSASCIIStringEncoding] forCharacteristic:self.CBCharacteristic type:CBCharacteristicWriteWithResponse];
  }
}

- (void)setNotifyValue:(BOOL)enabled  {
  [self.CBCharacteristic.service.peripheral setNotifyValue:enabled forCharacteristic:self.CBCharacteristic];
}

-(NSString *) randomStringWithLength: (int) len {
  
  NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
  
  for (int i = 0; i < len; i++) {
    [randomString appendFormat: @"%C", [letters characterAtIndex:(NSUInteger)arc4random_uniform((u_int32_t)[letters length])]];
  }
  
  return randomString;
}

@end
