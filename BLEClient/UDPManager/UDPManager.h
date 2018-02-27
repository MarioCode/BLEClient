//
//  UDPManager.h
//  BLEClient
//
//  Created by Anton Makarov on 13.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
#import "AMPeripheral.h"

//@class AMPeripheral;

@interface UDPManager : NSObject

@property (nonatomic, strong) AMPeripheral *peripheral;

- (void)didSendDataWithValue:(NSData *) data;
- (void)updateConnectToPort:(NSInteger) port;
- (void)disconnectSocket;

@end
