//
//  BLEManager.m
//  BLEClient
//
//  Created by Anton Makarov on 15.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "BLEManager.h"



@interface BLEManager () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *trackerPeripheral;

@end

@implementation BLEManager

- (id)init {
  self = [super init];
  if (self != nil)
  {
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

    _periphWithChar  = [[NSMutableDictionary alloc] init];
    _peripheralList = [[NSMutableArray alloc] init];
    _characteristicslList = [[NSMutableArray alloc] init];
    _peripheryInfo = [PeripheryInfo sharedInstance];
  }
  
  return self;
}

+ (instancetype)sharedInstance {
  
  static BLEManager *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    if (sharedManager == nil) {
      sharedManager = [[BLEManager alloc] init];
    }
  });
  
  return sharedManager;
}


#pragma mark -
#pragma mark Bluetooth Low Energy


// Update status of central manager (current device)
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
  
  switch (central.state) {
    case CBManagerStateUnknown:
    case CBManagerStateResetting:
    case CBManagerStateUnsupported:
    case CBManagerStateUnauthorized:
    case CBManagerStatePoweredOff:
      [self.delegate changeStatusLabel:@"Search status: BLE Off" withType:@"Scanning"];
      NSLog(@"Error... Check Bluetooth connection.");
      break;
      
    case CBManagerStatePoweredOn:
      [self.delegate changeStatusLabel:@"Bluetooth is active!" withType:@"Scanning"];
      NSLog(@"Bluetooth is active!");
      break;
  }
}


// Find peripheral devices and update table
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
  
  if ([peripheral.name isEqual: @"G5 SE"] || [peripheral.name isEqual: @"Galaxy J2 Prime"]) {
    CBPeripheral *per = peripheral;
    per.delegate = self;
    
    [_centralManager connectPeripheral:per options:nil];
    
    if (![_peripheralList containsObject:peripheral])
      [_peripheralList addObject:peripheral];
    
    [self.delegate reloadTable:@"Devices"];
    NSLog(@"Connecting to peripheral %@", per.name);
  }
}


// Connect to selected peripheral device
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
  [self.delegate changeStatusLabel:@"Connect status: Connected!" withType:@"Connect"];
  [self.delegate changeServiceUUIDLabel: [NSString stringWithFormat:@"%lu", (unsigned long)_peripheryInfo.services.count]];
  [self clearData];
  
  NSLog(@"Connected!");
}


// Discover characteristics for services
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
  
  for (CBService *service in peripheral.services) {
    NSLog(@"Service: %@", service);
    [peripheral discoverCharacteristics:_peripheryInfo.characteristics forService:service];
  }
}

// - didDiscoverCharacteristicsForService
// Characteristics for services
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
  
  if (error) {
    NSLog(@"Error");
    return;
  }
  
  for (CBCharacteristic *characteristic in service.characteristics) {
    
    if (![_characteristicslList containsObject:characteristic])
      [_characteristicslList addObject:characteristic];
    
    if (characteristic.properties & CBCharacteristicPropertyRead)
      [peripheral readValueForCharacteristic:characteristic];
    
    if (characteristic.properties & CBCharacteristicPropertyNotify)
      [peripheral setNotifyValue:true forCharacteristic:characteristic];
  }
  
  [self.delegate reloadTable:@"Characteristics"];
}


// Getting service characteristics (read)
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
  
  if (error) {
    NSLog(@"Error");
    return;
  }
  
  NSLog(@"Read data: %@", [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
  
  for (CBCharacteristic __strong *charact in _characteristicslList)
    if ([charact isEqual:characteristic])
      charact = characteristic;
  
  [self.delegate reloadTable:@"Characteristics"];
}


// Connect is fail
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  
  NSLog(@"Failed to connect");
  [self.delegate changeStatusLabel:@"Connect status: Failed!" withType:@"Connect"];
}


// Disconnected
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  
  NSLog(@"Disconnect from %@", peripheral.identifier.UUIDString);
  [self.delegate changeStatusLabel:@"Connect status: Disconnect" withType:@"Connect"];
  
  //[self startScanning:1 with:true];
  for (CBPeripheral *p in _peripheralList) {
    if ([p isEqual:peripheral])
      [_centralManager connectPeripheral:p options:nil];
  }
}


#pragma mark -
#pragma mark Basic Methods


// Start scanning
- (void)startScanning: (int)typeScan with:(BOOL)allScan {
  if (_centralManager.isScanning) {
    NSLog(@"Central Manager is already scanning!!");
    return;
  }
  
  if (!_isScanning) {
    
    // Clear current data before new scanning
    [self clearData];
    
    _isScanning = true;
    
    NSLog(@"Start scanning...");
    
    // If you choose to scan all devices, then search and work in the background will stop working
    if (allScan) {
      [_centralManager scanForPeripheralsWithServices:nil options:nil];
    } else {
      [_centralManager scanForPeripheralsWithServices:_peripheryInfo.services options:nil];
    }
    
    // End the scan after 5 seconds
    if (typeScan == 1) {
      [NSTimer scheduledTimerWithTimeInterval:5.0
                                       target:self
                                     selector:@selector(stopScanning)
                                     userInfo:nil
                                      repeats:NO];
    }
  }
}


// Read data from select characteristic
- (void)readData: (NSInteger)deviceIndex withCharIndex:(NSInteger)charIndex {
  
  if (_characteristicslList.count == 0)
    return;
  
  CBCharacteristic *ch = [_characteristicslList objectAtIndex:charIndex];
  [[_peripheralList objectAtIndex:deviceIndex] readValueForCharacteristic:ch];
}


// Write new value for device's characteristic
- (void)writeData: (NSInteger)deviceIndex withCharIndex:(NSInteger)charIndex withText:(NSString *)text {
  if (_characteristicslList.count == 0)
    return;
  
  [[_peripheralList objectAtIndex:deviceIndex] writeValue:[text dataUsingEncoding:NSASCIIStringEncoding]
                                        forCharacteristic:[_characteristicslList objectAtIndex:charIndex] type:CBCharacteristicWriteWithoutResponse];
}


// Get CBManager state
- (NSString *)managerState {
  if (_centralManager.state == CBManagerStatePoweredOn)
    return @"On";
  
  return @"Off";
}


// Stop scanning
- (void)stopScanning {
  NSLog(@"Stop");
  
  for (CBPeripheral *p in _peripheralList) {
    [p discoverServices: _peripheryInfo.services];
  }
  
  _isScanning = false;
  [self.delegate stopScan];
  [_centralManager stopScan];
}


// Clearing current data
- (void) clearData {
  
  [_characteristicslList removeAllObjects];
  [self.delegate reloadTable:@"Devices"];
  [self.delegate reloadTable:@"Characteristics"];
}
@end
