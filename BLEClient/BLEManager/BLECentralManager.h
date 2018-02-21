//
//  CentralManager.h
//  BLEClient
//
//  Created by Anton Makarov on 20.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Periphery.h"
#import "AMPeripheral.h"

@interface BLECentralManager : NSObject <CBCentralManagerDelegate>

@property (nonatomic, readonly) CBCentralManager *CBCentralManager;
@property (nonatomic, readonly) NSMutableDictionary *peripherals;
@property (nonatomic, readonly) PeripheryInfo *peripheryInfo;

+ (instancetype)sharedManager;

- (void)scanForPeripherals;
- (void)stopScanForPeripherals;

- (void)connectPeripheral:(AMPeripheral *)peripheral;
- (void)disconnectPeripheral:(AMPeripheral *)peripheral;

@end
