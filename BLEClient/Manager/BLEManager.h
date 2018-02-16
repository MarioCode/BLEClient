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

@protocol BLEManagerDelegate <NSObject>

- (void)changeStatusLabel: (NSString *)statusText withType:(NSString *)type;
- (void)reloadTable: (NSString *)table;
- (void)changeServiceUUIDLabel: (NSString *)uuidLabel;
- (void)stopScan;

@end

@interface BLEManager : NSObject

@property (nonatomic, weak) id <BLEManagerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray <CBPeripheral *> *peripheralList;
@property (nonatomic, strong) NSMutableArray <CBCharacteristic *> *characteristicslList;
@property (nonatomic, strong) NSMutableArray *charValuelList;

- (void)startScanning: (int)typeScan with:(BOOL)allScan;
- (void)stopScanning;
- (void)clearData;
- (void)readData: (NSInteger)index;
- (void)writeData: (NSInteger)index with:(NSString *)text;
- (void)setNewPeripheral: (NSInteger)index;
- (void)doDisconnect;
- (NSString *)managerState;

@end
