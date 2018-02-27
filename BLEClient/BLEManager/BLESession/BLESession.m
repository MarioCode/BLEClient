//
//  BLESession.m
//  BLEClient
//
//  Created by Anton Makarov on 26.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "BLESession.h"

@implementation BLESession

- (id)init
{
  return [self initWith:nil];
}

- (id)initWithObjects:(AMPeripheral *) peripheral {
  return [self initWith:peripheral];
}


- (id)initWith:(AMPeripheral *)peripheral {
  
  self = [super init];
  
  if (self) {
    if (peripheral == nil) {
      peripheral = [[AMPeripheral alloc] init];
    } else {
      _peripheral = [[AMPeripheral alloc] initWith:peripheral.CBPeripheral];
      _udpSocket = [[UDPManager alloc] init];
      
      _peripheral.udpManager = _udpSocket;
      _udpSocket.peripheral = _peripheral;
    }
  }

  return self;
}

@end
