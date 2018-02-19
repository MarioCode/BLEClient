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
   if (self)
     [self initBLEManager];
  
  return self;
}

+ (BLEManager *)sharedInstance {
  static dispatch_once_t onceToken;
  static BLEManager *singleton = nil;
  dispatch_once(&onceToken, ^{
    singleton = [[BLEManager alloc] init];
  });
  return singleton;
}


- (void)initBLEManager {
  
  _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
  _peripheralList = [[NSMutableArray alloc] init];
  _characteristicslList = [[NSMutableArray alloc] init];
  _charValuelList = [[NSMutableArray alloc] init];
  _peripheryInfo = [PeripheryInfo sharedInstance];
}


#pragma mark -
#pragma mark Bluetooth Low Energy


// - centralManagerDidUpdateState
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


// - didDiscoverPeripheral
// Find peripheral devices and update table
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
  
  if (RSSI.intValue < -30) {
    // return;
    // Uncomment above to ignore device with less signal strength
  }
  
  NSString *name = peripheral.name ? peripheral.name : @"nil";
  
  if ([name isEqual: _peripheryInfo.deviceName]) {
    // Uncomment this "return" to get the whole list of devices
    //return;
    
    [self stopScanning];
    _trackerPeripheral = peripheral;
    _trackerPeripheral.delegate = self;
    [_centralManager connectPeripheral:_trackerPeripheral options:nil];
  }
  
  if (![_peripheralList containsObject:peripheral])
    [_peripheralList addObject:peripheral];
  [self.delegate reloadTable:@"Devices"];
}

// - didConnectPeripheral
// Connect to selected peripheral device
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
  [self.delegate changeStatusLabel:@"Connect status: Connected!" withType:@"Connect"];
  [self clearData];
  
  NSLog(@"Connected!");
  [_trackerPeripheral discoverServices:_peripheryInfo.services];
  
  if (_peripheryInfo.services.count > 1)
    [self.delegate changeServiceUUIDLabel:@"More than one"];
  else
    [self.delegate changeServiceUUIDLabel:[[_peripheryInfo.services objectAtIndex:0] UUIDString]];
}


// - didDiscoverServices
// Discover characteristics for services
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
  
  for (CBService *service in _trackerPeripheral.services) {
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

// - didUpdateValueForCharacteristic
// Getting service characteristics (read)
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
  
  if (error) {
    NSLog(@"Error");
    return;
  }
  
  NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
  NSLog(@"Read data: %@", stringFromData);
  
  int count = 0;
  if (_charValuelList.count == _characteristicslList.count) {
    for (CBCharacteristic *charact in _characteristicslList) {
      if ([charact isEqual:characteristic])
        [_charValuelList replaceObjectAtIndex:count withObject:stringFromData];
      
      count++;
    }
  } else {
    [_charValuelList addObject:stringFromData];
  }
  
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
  
  [_centralManager connectPeripheral:_trackerPeripheral options:nil];
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
- (void)readData: (NSInteger)index {
  if (_characteristicslList.count == 0)
    return;
  
  CBCharacteristic *ch = [_characteristicslList objectAtIndex:index];
  
  [_trackerPeripheral readValueForCharacteristic:ch];
}


// Write new value for device's characteristic
- (void)writeData: (NSInteger)index with:(NSString *)text {
  if (_characteristicslList.count == 0)
    return;
  
  [_trackerPeripheral writeValue:[text dataUsingEncoding:NSASCIIStringEncoding]
               forCharacteristic:[_characteristicslList
                                  objectAtIndex:index] type:CBCharacteristicWriteWithoutResponse];
}


// Update main peripheral device
- (void)setNewPeripheral: (NSInteger)index {
  
  _trackerPeripheral = [_peripheralList objectAtIndex:index];
  _trackerPeripheral.delegate = self;
  
  NSLog(@"Connecting to peripheral %@", _trackerPeripheral.name);
  
 [_centralManager connectPeripheral:_trackerPeripheral options:nil];
}


// After manual input, install ONLY ONE UUID
- (void)setServiceUUID: (NSString *)uuid {
  [_peripheryInfo.services removeAllObjects];
  [_peripheryInfo.services addObject:[CBUUID UUIDWithString:uuid]];
}


// Get CBManager state
- (NSString *)managerState {
  if (_centralManager.state == CBManagerStatePoweredOn)
    return @"On";
  
  return @"Off";
}


// Hands disconnected
- (void)doDisconnect {
  if (_trackerPeripheral != nil) {
    [_centralManager cancelPeripheralConnection:_trackerPeripheral];
    [self clearData];
    _isScanning = false;
  }
}


// Stop scanning
- (void)stopScanning {
  NSLog(@"Stop");
  _isScanning = false;
  [self.delegate stopScan];
  [_centralManager stopScan];
}


// Clearing current data
- (void) clearData {
  [_charValuelList removeAllObjects];
  [_characteristicslList removeAllObjects];
  [self.delegate reloadTable:@"Devices"];
  [self.delegate reloadTable:@"Characteristics"];
}
@end
