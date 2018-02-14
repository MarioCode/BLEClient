//
//  UDPManager.m
//  BLEClient
//
//  Created by Anton Makarov on 13.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "UDPManager.h"

#define SOCKADRS  "xx.xx.xxx.xxx"
#define SOCKPORT  9999

@interface UDPManager ()<GCDAsyncUdpSocketDelegate>

@property (nonatomic) GCDAsyncUdpSocket* udpSocket;
@property (nonatomic) long tag;

@end


@implementation UDPManager

- (id)init {
  self = [super init];
  [self initUdp];
  
  return self;
}


// Initialization UDP Socket
- (void) initUdp {
  
  NSError *error = nil;
  _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
  
  if (![_udpSocket bindToPort:0 error:&error]) {
    NSLog(@"Error binding: %@", error);
    return;
  }
  
  if (![_udpSocket beginReceiving:&error]) {
    NSLog(@"Error receiving: %@", error);
    return;
  }
  
  NSLog(@"Init --> Ready");
}


// Receive data from server
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address withFilterContext:(id)filterContext {
  
  //NSString *msg = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  //[[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSASCIIStringEncoding]
 
  NSString *host = nil;
  uint16_t port = 0;
  [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];

  NSLog(@"Receive data: %@ /nfrom: %@:%hu", data, host, port);
}


// Send message via UDP (HEX data)
- (void)sendMsg:(NSString *) textMsg {

  NSString *msg = textMsg;
  if ([msg length] == 0) {
    NSLog(@"Message required (length = 0)");
    return;
  }
  
  NSString *str1 = @"A6CC000000010ED9805A00000000000000000000000000004E008303F432003839343231303";
  NSString *str2 = @"2343830303131303935383231007B080D8600000A7B080D860000127B080E86000010C25DBF1";
  NSString* hexDataString = [NSString stringWithFormat:@"%@%@", str1, str2];

  NSData *data = [self dataFromHexString:hexDataString];
  
  [_udpSocket sendData:data toHost:@SOCKADRS port:SOCKPORT withTimeout:-1 tag: _tag++];
  NSLog(@"SENT (%i): %@", (int)_tag, msg);
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

@end
