//
//  AMCharacteristics.h
//  BLEClient
//
//  Created by Anton Makarov on 20.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef enum {
    READ_UDP = 1,
    WRITE_UDP = 2,
    LOCATION = 3
} CharacteristicType;

@interface AMCharacteristics : NSObject

@property (nonatomic, strong, readonly) CBCharacteristic *CBCharacteristic;
@property (nonatomic, readwrite) CharacteristicType characteristicType;

- (instancetype)initWith:(CBCharacteristic *)cbCharacteristic;

- (void)writeValue:(NSData *)data;
- (void)setNotifyValue:(BOOL)enabled;

@end
