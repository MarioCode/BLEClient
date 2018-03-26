//
//  BLEManager.h
//  BLEClient
//
//  Created by Anton Makarov on 15.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Periphery.h"

#define DEFAULT_TIMEOUT_INTERVAL 5;

#pragma mark -
#pragma mark protocol

@protocol BLEManagerDelegate <NSObject>

- (void)changeStatusLabel: (NSString *)statusText withType:(NSString *)type;
- (void)reloadTable: (NSString *)table;
- (void)changeServiceUUIDLabel: (NSString *)uuidLabel;
- (void)stopScan;

@end

#pragma mark -
#pragma mark BLEManager

@interface BLEManager : NSObject

@property (nonatomic, weak) id <BLEManagerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray <CBPeripheral *> *peripheralList;
@property (nonatomic, strong) NSMutableArray <CBCharacteristic *> *characteristicslList;
@property (nonatomic, strong) PeripheryInfo *peripheryInfo;
@property (nonatomic, readonly) NSMutableDictionary *periphWithChar;

@property BOOL isScanning;

+ (instancetype)sharedInstance;

- (void)startScanning: (int)typeScan with:(BOOL)allScan;
- (void)stopScanning;
- (void)clearData;
- (void)readData: (NSInteger)deviceIndex withCharIndex:(NSInteger)charIndex;
- (void)writeData: (NSInteger)deviceIndex withCharIndex:(NSInteger)charIndex withText:(NSString *)text;
- (NSString *)managerState;

@end
