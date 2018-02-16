//
//  UDPManager.h
//  BLEClient
//
//  Created by Anton Makarov on 13.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

@interface UDPManager : NSObject

- (void)sendMsg:(NSString *) textMsg;

@end
