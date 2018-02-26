//
//  BridgeDelegate.m
//  BLEClient
//
//  Created by Anton Makarov on 25.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -
#pragma mark protocol

@protocol BleToUdpBridgeDelegate <NSObject>

- (void)didSendData: (NSData *)data toPort:(NSInteger)port;

@end

@protocol UdpToBleBridgeDelegate <NSObject>

- (void)didSendData: (NSData *)data toPort:(NSInteger)port;

@end
