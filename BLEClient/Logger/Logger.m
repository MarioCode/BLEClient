//
//  Logger.m
//  BLEClient
//
//  Created by Anton Makarov on 05.03.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "Logger.h"

@implementation Logger

+ (Logger *)sharedManager {
  static Logger *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^(void) {
    if (sharedManager == nil) {
      sharedManager = [[Logger alloc] init];
    }
  });
  
  return sharedManager;
}

- (id)init {
  self = [super init];
  
  return self;
}

- (void)sendLogToMainVC:(NSString *)log {
  NSDictionary *dict = [NSDictionary dictionaryWithObject:log forKey:@"Log"];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"Logger" object:nil userInfo:dict];
}

@end
