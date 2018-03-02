//
//  UDPManager.h
//  BLEClient
//
//  Created by Anton Makarov on 13.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

@class AMPeripheral;

@interface UDPManager : NSObject

@property (nonatomic, strong) AMPeripheral *peripheral;

- (void)closeSocket;
- (void)didSendDataWithValue:(NSData *) data;

@end
