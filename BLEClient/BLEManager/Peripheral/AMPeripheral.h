//
//  AMPeripheral.h
//  BLEClient
//
//  Created by Anton Makarov on 20.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LocationManager.h"
#import "Periphery.h"
#import "AMService.h"

@class UDPManager;

@interface AMPeripheral : NSObject <CBPeripheralDelegate>

@property (nonatomic, strong, readonly) CBPeripheral *CBPeripheral;
@property (nonatomic, strong, readonly) NSMutableDictionary *services;
@property (nonatomic, strong) UDPManager *udpManager;
@property (nonatomic, assign) BOOL isCanUpdateCoordinate;

- (instancetype)initWith:(CBPeripheral *)cbPeripheral;

- (BOOL)isConnected;
- (void)receivingDataFromUDP:(NSData *)recieveData;
- (void)didConnectAndDiscoverServices;
- (void)updateDeviceLocation:(CLLocation *)location;
- (void)setForCanUpdateCoordinate:(NSInteger)RSSI;

@end
