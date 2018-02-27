//
//  AMPeripheral.h
//  BLEClient
//
//  Created by Anton Makarov on 20.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Periphery.h"
#import "AMService.h"
//#import "UDPManager.h"

@class UDPManager;

@interface AMPeripheral : NSObject <CBPeripheralDelegate>

@property (nonatomic, strong, readonly) CBPeripheral *CBPeripheral;
@property (nonatomic, strong, readonly) NSMutableDictionary *services;
@property (nonatomic, strong) UDPManager *udpManager;
@property (nonatomic, readonly) NSInteger udpPort;

- (instancetype)initWith:(CBPeripheral *)cbPeripheral;

- (void)sendRequestData:(NSData *)requestData;
- (BOOL)isConnected;

// Handling CBCentralManager
- (void)didConnect;
- (void)discoverServices;
- (void)didFailToConnectWithError:(NSError *)error;
- (void)didDisconnectWithError:(NSError *)error;
- (void)didUpdateDeviceLocation:(NSString *)coordinates;
@end
