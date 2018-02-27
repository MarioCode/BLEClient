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

@property (nonatomic, strong, readonly) CBCharacteristic *CBCharacteristic;
@property (nonatomic, readwrite) NSString *charValue;
@property (nonatomic) BOOL isWrite;

- (instancetype)initWith:(CBCharacteristic *)cbCharacteristic;

- (void)readValue;
- (void)writeValue:(NSString *)value;
- (void)setNotifyValue:(BOOL)enabled;

@end
