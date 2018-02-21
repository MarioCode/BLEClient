//
//  AMCharacteristics.m
//  BLEClient
//
//  Created by Anton Makarov on 20.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "AMCharacteristics.h"

@interface AMCharacteristics ()

@property (nonatomic, copy) AMCharacteristicUpdateValueBlock autoUpdateValueBlock;

@property (nonatomic, copy) AMCharacteristicUpdateValueBlock updateValueBlock;
@property (nonatomic, copy) AMCharacteristicWriteValueBlock writeValueBlock;
@property (nonatomic, copy) AMCharacteristicUpdateNotificationStateBlock updateNotificationStateBlock;

@property (nonatomic, getter = isUpdateValueInProgress) BOOL updateValueInProgress;
@property (nonatomic, getter = isWriteValueInProgress) BOOL writeValueInProgress;
@property (nonatomic, getter = isUpdateNotificationInProgress) BOOL updateNotificationStateInProgress;

//@property (nonatomic) VYMessage *writeMessage;
//@property (nonatomic) VYMutableMessage *readMessage;

@end

@implementation AMCharacteristics

#pragma mark -
#pragma mark Object Init

- (instancetype)init {
  return [self initWithCBCharacteristic:nil];
}

+ (instancetype)characteristicWithCBCharacteristic:(CBCharacteristic *)cbCharacteristic {
  return [[self alloc] initWithCBCharacteristic:cbCharacteristic];
}


- (instancetype)initWithCBCharacteristic:(CBCharacteristic *)cbCharacteristic {
  self = [super init];
  
  if (self != nil) {
    if (cbCharacteristic != nil)
      _CBCharacteristic = cbCharacteristic;
    else
      self = nil;
  }
  
  return self;
}

#pragma mark -
#pragma mark Methods

- (void)setUpdateValueBlock:(AMCharacteristicUpdateValueBlock)block {
  self.autoUpdateValueBlock = block;
}

- (void)readValueWithCompletion:(AMCharacteristicUpdateValueBlock)block {
  if ([self isUpdateValueInProgress])
    NSLog(@"Another read value for characteristic task is in progress.");
  
  if (![self isUpdateValueInProgress]) {
    self.updateValueInProgress = YES;
    self.updateValueBlock = block;
    
    [self.CBCharacteristic.service.peripheral readValueForCharacteristic:self.CBCharacteristic];
  }
}

- (void)writeValue:(NSData *)value completion:(AMCharacteristicWriteValueBlock)block
{
  if ([self isUpdateValueInProgress])
    NSLog(@"Another write value for characteristic task is in progress.");
  
  if (![self isWriteValueInProgress]) {
    self.writeValueInProgress = YES;
    self.writeValueBlock = block;
    
    NSString *writeMessage = [self randomStringWithLength:7];
    [self writeValue: writeMessage];
  }
}

- (void)setNotifyValue:(BOOL)enabled completion:(AMCharacteristicUpdateNotificationStateBlock)block
{
  if ([self isUpdateValueInProgress])
    NSLog(@"Another set notify value for characteristic task is in progress.");
  
  if (![self isUpdateNotificationInProgress]) {
    self.updateNotificationStateInProgress = YES;
    self.updateNotificationStateBlock = block;
    
    [self.CBCharacteristic.service.peripheral setNotifyValue:enabled forCharacteristic:self.CBCharacteristic];
  }
}

#pragma mark -
#pragma mark Handling CBPeripheral Callbacks

- (void)didUpdateValueWithError:(NSError *)error {
  
  if (error != nil) {
    if (self.autoUpdateValueBlock != nil)
      self.autoUpdateValueBlock(nil, error);
    
    if ([self isUpdateValueInProgress]) {
      if (self.updateValueBlock != nil) {
        self.updateValueBlock(nil, error);
        self.updateValueBlock = nil;
      }
      
      //self.readMessage = nil;
      self.updateValueInProgress = NO;
    }
  }
  else
  {
   // VYMessageChunk *chunk = [VYMessageChunk messageChunkWithData:self.CBCharacteristic.value];
    
//    if ([chunk isFirst])
//    {
//      self.readMessage = [VYMutableMessage messageWithChunk:chunk];
//    }
//    else
//    {
//      [self.readMessage addChunk:chunk];
//    }
//
//    if ([chunk isLast])
//    {
//      if (self.autoUpdateValueBlock != nil)
//      {
//        self.autoUpdateValueBlock(self.readMessage.data, error);
//      }
//
//      if ([self isUpdateValueInProgress])
//      {
//        if (self.updateValueBlock != nil)
//        {
//          self.updateValueBlock(self.readMessage.data, error);
//          self.updateValueBlock = nil;
//        }
//
//        self.readMessage = nil;
//        self.updateValueInProgress = NO;
//      }
//    }
  }
}

- (void)didWriteValueWithError:(NSError *)error
{
  if (error != nil)
  {
    if ([self isWriteValueInProgress])
    {
      if (self.writeValueBlock != nil)
      {
        self.writeValueBlock(nil, error);
        self.writeValueBlock = nil;
      }
      
      //self.writeMessage = nil;
      self.writeValueInProgress = NO;
    }
  }
  else
  {
//    if ([self isWriteValueInProgress])
//    {
//      if ([[self.writeMessage currentChunk] isLast])
//      {
//        if (self.writeValueBlock != nil)
//        {
//          self.writeValueBlock(self.writeMessage.data, error);
//          self.writeValueBlock = nil;
//        }
//
//        self.writeMessage = nil;
//        self.writeValueInProgress = NO;
//      }
//      else
//      {
//        [self writeValue:[self.writeMessage nextChunk].data];
//      }
//    }
  }
}

- (void)didUpdateNotificationStateWithError:(NSError *)error
{
  if ([self isUpdateNotificationInProgress])
  {
    if (self.updateNotificationStateBlock != nil)
    {
      self.updateNotificationStateBlock([self.CBCharacteristic isNotifying], error);
      self.updateNotificationStateBlock = nil;
    }
    
    self.updateNotificationStateInProgress = NO;
  }
}

#pragma mark -
#pragma mark Helpers

- (void)writeValue:(NSString *)txtData {
  
  [self.CBCharacteristic.service.peripheral writeValue:[txtData dataUsingEncoding:NSASCIIStringEncoding] forCharacteristic:self.CBCharacteristic type:CBCharacteristicWriteWithResponse];
}


-(NSString *) randomStringWithLength: (int) len {
  
  NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
  
  for (int i = 0; i < len; i++) {
    [randomString appendFormat: @"%C", [letters characterAtIndex:(NSUInteger)arc4random_uniform((u_int32_t)[letters length])]];
  }
  
  return randomString;
}

@end
