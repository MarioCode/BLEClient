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
#import "Logger.h"

@interface AMService: NSObject

@property (nonatomic, strong, readonly)CBService *Service;
@property (nonatomic, strong, readonly) NSMutableDictionary *characteristics;

- (instancetype)initWith:(CBService *)cbService;
- (void)discoverCharacteristics;

@end
