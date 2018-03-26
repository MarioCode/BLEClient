//
//  UDPManager.m
//  BLEClient
//
//  Created by Anton Makarov on 13.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "UDPManager.h"
#import "AMPeripheral.h"

#define SOCKADRS  "52.89.163.195"
#define SOCKPORT  8188

@interface UDPManager ()<GCDAsyncUdpSocketDelegate>

@property (nonatomic) GCDAsyncUdpSocket* udpSocket;
@property (nonatomic) long tag;

@end


@implementation UDPManager


#pragma mark -
#pragma mark Init


- (id)init {
  self = [super init];

  if (self != nil) {
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self updateConnectToPort:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSendDataWithValue:) name:@"BLETest" object:nil];
  }
  
  return self;
}


#pragma mark -
#pragma mark Base Methods


// Send message via UDP (HEX data)
- (void)didSendDataWithValue:(NSData *) data {
  
  [self.udpSocket sendData:data toHost:@SOCKADRS port:SOCKPORT withTimeout:-1 tag: self.tag++];
  
  NSString *log = [NSString stringWithFormat:@"UDP: Send data: (%i): %@", (int)self.tag, data];
  [[Logger sharedManager] sendLogToMainVC:log];
}


// Receive data from server
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address withFilterContext:(id)filterContext {
  
  NSString *host = nil;
  uint16_t port = 0;
  [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
  
  NSString *log = [NSString stringWithFormat:@"UDP: Receive data: %@. My port: %hu", data, self.udpSocket.localPort];
  [[Logger sharedManager] sendLogToMainVC:log];
  [self.peripheral receivingDataFromUDP:data];
}


// Update socket's port
- (void)updateConnectToPort:(NSInteger) port {
  
  NSError *error = nil;
  [self.udpSocket close];
  
  if (![self.udpSocket bindToPort:port error:&error]) {
    NSLog(@"Error binding: %@", error);
    return;
  }
  
  if (![self.udpSocket beginReceiving:&error]) {
    NSLog(@"Error receiving: %@", error);
    return;
  }
}


- (void)doDisconnectSocket {
  [self.udpSocket close];
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error {
    NSLog(@"UdpSocket did close");
}

#pragma mark -
#pragma mark Helpers


- (void)closeSocket {
  [self.udpSocket close];
}


@end
