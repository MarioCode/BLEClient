//
//  AMService.h
//  BLEClient
//
//  Created by Anton Makarov on 20.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Periphery.h"


@interface AMService: NSObject

@property (nonatomic, readonly) CBService *Service;
@property (nonatomic, readonly) NSMutableDictionary *characteristics;
@property (nonatomic, readonly) PeripheryInfo *peripheryInfo;
@property (nonatomic) BOOL discoverCharacteristicsInProgress;

+ (instancetype)serviceWithCBService:(AMService *)cbService;
- (instancetype)initWithCBService:(AMService *)cbService;

- (void)discoverCharacteristics:(NSArray *)characteristicUUIDs;
- (void)didDiscoverCharacteristicsWithError:(NSError *)error;

@end
