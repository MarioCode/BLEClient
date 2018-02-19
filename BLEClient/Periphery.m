//
//  Periphery.m
//  BLEClient
//
//  Created by Anton Makarov on 09.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "Periphery.h"

@implementation PeripheryInfo

@synthesize services = _services;
@synthesize characteristics = _characteristics;
@synthesize deviceName = _deviceName;


+ (PeripheryInfo *)sharedInstance {
  static dispatch_once_t onceToken;
  static PeripheryInfo *instance = nil;
  dispatch_once(&onceToken, ^{
    instance = [[PeripheryInfo alloc] init];
  });
  return instance;
}


- (id)init {
  self = [super init];
  if (self) {
    _services = [[NSMutableArray <CBUUID *> alloc] init];
    [_services addObject:[CBUUID UUIDWithString:@"0000ffe1-0000-1000-8000-00805F8B34FB"]];
    [_services addObject:[CBUUID UUIDWithString:@"0000ffe5-0000-1000-8000-00805F8B34FB"]];

    _characteristics = [[NSMutableArray <CBUUID *> alloc] init];
    [_characteristics addObject:[CBUUID UUIDWithString:@"0000ffe2-0000-1000-8000-00805F8B34FB"]];

    _deviceName = @"G5 SE";
  }
  
  return self;
}

@end

