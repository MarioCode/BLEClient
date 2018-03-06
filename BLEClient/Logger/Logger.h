//
//  Logger.h
//  BLEClient
//
//  Created by Anton Makarov on 05.03.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NotificationCenter/NotificationCenter.h>

@interface Logger : NSObject

+ (Logger*)sharedManager;

- (void)sendLogToMainVC:(NSString *)log;

@end
