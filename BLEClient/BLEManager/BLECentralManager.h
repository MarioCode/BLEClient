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
#import "BridgeDelegate.h"

@interface BLECentralManager : NSObject <CBCentralManagerDelegate, UdpToBleBridgeDelegate>

@property (nonatomic, readonly) CBCentralManager *CBCentralManager;
@property (nonatomic, readonly) NSMutableDictionary *peripherals;

+ (instancetype)sharedManager;

- (void)scanForPeripherals;
- (void)stopScanForPeripherals;

- (void)connectPeripheral:(AMPeripheral *)peripheral;
- (void)disconnectPeripheral:(AMPeripheral *)peripheral;

- (void)getPeripheralInfo;

@end
