//
//  UDPManager.m
//  BLEClient
//
//  Created by Anton Makarov on 13.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "UDPManager.h"

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
  
  NSLog(@"Send - Current port: %hu", _udpSocket.localPort);
  
  NSString *str1 = @"A6CC000000010ED9805A00000000000000000000000000004E008303F432003839343231303";
  NSString *str2 = @"2343830303131303935383231007B080D8600000A7B080D860000127B080E86000010C25DBF1";
  NSString* hexDataString = [NSString stringWithFormat:@"%@%@", str1, str2];

  NSData *tmpData = [self dataFromHexString:hexDataString];
  
  [self.udpSocket sendData:tmpData toHost:@SOCKADRS port:SOCKPORT withTimeout:-1 tag: self.tag++];
  NSLog(@"SENT (%i)", (int)self.tag);
}


// Receive data from server
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address withFilterContext:(id)filterContext {
  
  NSString *host = nil;
  uint16_t port = 0;
  [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
  
  NSLog(@"Rcv - Current port: %hu", _udpSocket.localPort);
  NSLog(@"Receive data: %@ /nfrom: %@:%hu", data, host, port);
  [self.peripheral sendRequestData:data];
}


// Update socket's port
- (void)updateConnectToPort:(NSInteger) port {
  
  NSError *error = nil;
  [self.udpSocket close];
  
  if (![_udpSocket bindToPort:port error:&error]) {
    NSLog(@"Error binding: %@", error);
    return;
  }
  
  if (![self.udpSocket beginReceiving:&error]) {
    NSLog(@"Error receiving: %@", error);
    return;
  }
}


- (void)didSendData: (NSData *)data toPort:(NSInteger)port {
  if (self.udpSocket.localPort != port) {
    [self updateConnectToPort:port];
  }
  
  //[self didSendDataWithValue:data];
}


- (void)disconnectSocket {
  [_udpSocket close];
}


#pragma mark -
#pragma mark Helpers


// Transform HEX Data from NSString to NSData
- (NSData *)dataFromHexString:(NSString *) hexString {
  
  const char *chars = [hexString UTF8String];
  unsigned long i = 0, len = hexString.length;
  
  NSMutableData *data = [NSMutableData dataWithCapacity: len / 2];
  char byteChars[3] = {'\0','\0','\0'};
  unsigned long wholeByte;
  
  while (i < len) {
    byteChars[0] = chars[i++];
    byteChars[1] = chars[i++];
    wholeByte = strtoul(byteChars, NULL, 16);
    [data appendBytes:&wholeByte length:1];
  }
  
  return data;
}

@end
