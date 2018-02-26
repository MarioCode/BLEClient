//
//  UDPManager.h
//  BLEClient
//
//  Created by Anton Makarov on 13.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
#import "BridgeDelegate.h"
#import "AMPeripheral.h"

@interface UDPManager : NSObject < BleToUdpBridgeDelegate >

+ (UDPManager *)shareUDPSocket;

- (void)didSendDataWithValue:(NSData *) data;
- (void)updateConnectToPort:(NSInteger) port;
@end
