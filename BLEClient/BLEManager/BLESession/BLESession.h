//
//  BLESession.h
//  BLEClient
//
//  Created by Anton Makarov on 26.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMPeripheral.h"
#import "UDPManager.h"

@interface BLESession : NSObject

@property (nonatomic, strong, readonly) AMPeripheral *peripheral;
@property (nonatomic, strong, readonly) UDPManager *udpSocket;

- (id)initWith:(AMPeripheral *)peripheral;

@end
