//
//  Periphery.h
//  BLEClient
//
//  Created by Anton Makarov on 09.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface PeripheryInfo : NSObject
{
  NSMutableArray <CBUUID *> *_services;
  NSMutableArray <CBUUID *> *_characteristics;
  NSString *_deviceName;
}

+ (PeripheryInfo *)sharedInstance;

@property(strong, nonatomic, readwrite) NSMutableArray <CBUUID *> *services;
@property(strong, nonatomic, readwrite) NSMutableArray <CBUUID *> *characteristics;
@property(strong, nonatomic, readwrite) NSString *deviceName;

@end







