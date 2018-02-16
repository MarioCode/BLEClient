//
//  Periphery.h
//  BLEClient
//
//  Created by Anton Makarov on 09.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>

extern struct PeripheryInfoStruct
{
  __unsafe_unretained NSString * pFirstService;
  __unsafe_unretained NSString * pSecondService;
  __unsafe_unretained NSString * pCharacteristic;
  __unsafe_unretained NSString * const deviceName;
} PeripheryInfo;






