//
//  CentralManager.h
//  BLEClient
//
//  Created by Anton Makarov on 20.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <NotificationCenter/NotificationCenter.h>
#import "Periphery.h"
#import "AMPeripheral.h"
#import "BLESession.h"
#import "AMCharacteristics.h"
#import "LocationManager.h"

@interface BLECentralManager : NSObject <CBCentralManagerDelegate>

@property (nonatomic, strong, readonly) CBCentralManager *CBCentralManager;
@property (nonatomic, strong, readonly) NSMutableDictionary *sessions;

+ (instancetype)sharedManager;

- (void)scanForPeripherals;
- (void)stopScanForPeripherals;
- (void)connectPeripheral:(AMPeripheral *)peripheral;
- (void)disconnectPeripheral:(AMPeripheral *)peripheral;
- (void)getAllInfo;

@end
