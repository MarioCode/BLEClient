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

+ (instancetype)serviceWithCBService:(CBService *)cbService;
- (instancetype)initWithCBService:(CBService *)cbService;

- (void)discoverCharacteristics;

@end
