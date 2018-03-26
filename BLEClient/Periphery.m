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
    [_services addObject:[CBUUID UUIDWithString:@"0000FF00-0000-1000-8000-00805F9B34FB"]];

    _characteristics = [[NSMutableArray <CBUUID *> alloc] init];
    [_characteristics addObject:[CBUUID UUIDWithString:@"0000FF01-0000-1000-8000-00805F9B34FB"]];
    [_characteristics addObject:[CBUUID UUIDWithString:@"0000FF02-0000-1000-8000-00805F9B34FB"]];
    [_characteristics addObject:[CBUUID UUIDWithString:@"0000FF03-0000-1000-8000-00805F9B34FB"]];

    _deviceName = @"Mishiko M103";
  }
  
  return self;
}

@end

