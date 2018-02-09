//
//  Periphery.h
//  BLEClient
//
//  Created by Anton Makarov on 09.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const struct PeripheryInfoStruct
{
  __unsafe_unretained NSString * const pService;
  __unsafe_unretained NSString * const pCharacteristics;
  __unsafe_unretained NSString * const deviceName;
} PeripheryInfo;






