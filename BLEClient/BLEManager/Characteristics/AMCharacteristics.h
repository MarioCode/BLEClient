//
//  AMCharacteristics.h
//  BLEClient
//
//  Created by Anton Makarov on 20.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface AMCharacteristics : NSObject

@property (nonatomic, readonly) CBCharacteristic *CBCharacteristic;
@property (nonatomic) NSString *charValue;

+ (instancetype)characteristicWithCBCharacteristic:(CBCharacteristic *)cbCharacteristic;
- (instancetype)initWithCBCharacteristic:(CBCharacteristic *)cbCharacteristic;

- (void)readValue;
- (void)writeValue:(NSData *)value;
- (void)setNotifyValue:(BOOL)enabled;

@end
