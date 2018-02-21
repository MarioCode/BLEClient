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

- (id)init {
  self = [super init];

  if (self) {
    _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self updateConnect:60000];
  }
  
  return self;
}


// Receive data from server
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address withFilterContext:(id)filterContext {
  
  NSString *host = nil;
  uint16_t port = 0;
  [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];

  NSLog(@"Receive data: %@ /nfrom: %@:%hu", data, host, port);
}


// Send message via UDP (HEX data)
- (void)didSendData {
  
  NSLog(@"Current port: %hu", _udpSocket.localPort);
  
  NSString *str1 = @"A6CC000000010ED9805A00000000000000000000000000004E008303F432003839343231303";
  NSString *str2 = @"2343830303131303935383231007B080D8600000A7B080D860000127B080E86000010C25DBF1";
  NSString* hexDataString = [NSString stringWithFormat:@"%@%@", str1, str2];

  NSData *data = [self dataFromHexString:hexDataString];
  
  [_udpSocket sendData:data toHost:@SOCKADRS port:SOCKPORT withTimeout:-1 tag: _tag++];
  NSLog(@"SENT (%i)", (int)_tag);
}


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


- (void)updateConnect:(NSInteger) port {
  
  NSError *error = nil;
  [_udpSocket close];
  
  if (![_udpSocket bindToPort:port error:&error]) {
    NSLog(@"Error binding: %@", error);
    return;
  }
  
  if (![_udpSocket beginReceiving:&error]) {
    NSLog(@"Error receiving: %@", error);
    return;
  }
}

@end
