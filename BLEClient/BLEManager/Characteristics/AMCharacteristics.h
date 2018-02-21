//
//  AMCharacteristics.h
//  BLEClient
//
//  Created by Anton Makarov on 20.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void (^AMCharacteristicUpdateValueBlock)(NSData *value, NSError *error);
typedef void (^AMCharacteristicWriteValueBlock)(NSData *value, NSError *error);
typedef void (^AMCharacteristicUpdateNotificationStateBlock)(BOOL isNotifying, NSError *error);

@interface AMCharacteristics : NSObject

@property (nonatomic, readonly) CBCharacteristic *CBCharacteristic;

+ (instancetype)characteristicWithCBCharacteristic:(CBCharacteristic *)cbCharacteristic;
- (instancetype)initWithCBCharacteristic:(CBCharacteristic *)cbCharacteristic;

- (void)setUpdateValueBlock:(AMCharacteristicUpdateValueBlock)block;

- (void)readValueWithCompletion:(AMCharacteristicUpdateValueBlock)block;
- (void)writeValue:(NSData *)value completion:(AMCharacteristicWriteValueBlock)block;
- (void)setNotifyValue:(BOOL)enabled completion:(AMCharacteristicUpdateNotificationStateBlock)block;

// Handling CBPeripheral callbacks.
- (void)didUpdateValueWithError:(NSError *)error;
- (void)didWriteValueWithError:(NSError *)error;
- (void)didUpdateNotificationStateWithError:(NSError *)error;

@end
