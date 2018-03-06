//
//  CentralManager.m
//  BLEClient
//
//  Created by Anton Makarov on 20.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "BLECentralManager.h"
#import "AMPeripheral.h"

@implementation BLECentralManager


#pragma mark -
#pragma mark Singleton


+ (instancetype)sharedManager {
  static BLECentralManager *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^(void) {
    if (sharedManager == nil) {
      sharedManager = [[super allocWithZone:NULL] init];
    }
  });
  
  return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone {
  return [self sharedManager];
}


#pragma mark -
#pragma mark Init


- (id)init {
  self = [super init];
  
  if (self != nil) {
    dispatch_queue_t queue = dispatch_queue_create("CentralManagerQueue", DISPATCH_QUEUE_SERIAL);

    _CBCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:nil];
    _sessions = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAndUpdateCoordinate) name:@"GetLocationNotification" object:nil];
  }
  
  return self;
}


#pragma mark -
#pragma mark Handheld Methods


// Start scanning for peripheral devices
- (void)scanForPeripherals {
  
  if (self.CBCentralManager.isScanning) {
    [[Logger sharedManager] sendLogToMainVC:@"ErrorCB: Central Manager is already scanning!!"];
    return;
  }
  
  if (self.sessions.count > 0) {
    for (CBUUID *  key in self.sessions) {
      BLESession *s = [self.sessions objectForKey:key];
      if (![s.peripheral isConnected]) {
  
        NSString *log = [NSString stringWithFormat:@"Info: Reconnection to existing session: Peripheral - %@, UDP - %@", s.peripheral.CBPeripheral, s.udpSocket];

        [[Logger sharedManager] sendLogToMainVC:log];
        [self.CBCentralManager connectPeripheral:s.peripheral.CBPeripheral options:nil];
      }
    }
    
   // [[Logger sharedManager] sendLogToMainVC:@"Info: Scan for other peripherals"];
   // [self.CBCentralManager scanForPeripheralsWithServices:[PeripheryInfo sharedInstance].services options:nil];
    return;
  }
  
  // проверка на подключенных, иначе скан фор периферал
  if (self.CBCentralManager.state == CBManagerStatePoweredOn) {
  
    [[Logger sharedManager] sendLogToMainVC:@"Info: Start scanning"];
    
    // nil services - searching all available devices
    NSArray <CBPeripheral*> *per = [self.CBCentralManager retrieveConnectedPeripheralsWithServices:[PeripheryInfo sharedInstance].services];
    
    if (per.count > 0) {
      [[Logger sharedManager] sendLogToMainVC:@"Info: Connection to existing connected devices"];

      for (int i = 0; i < per.count; i++) {
        AMPeripheral *peripheral = [[AMPeripheral alloc] initWith:per[i]];
        BLESession *session = [[BLESession alloc] initWith:peripheral];
        self.sessions[peripheral.CBPeripheral.identifier] = session;
        [self connectPeripheral:peripheral];
      }
    }
    
    //[[Logger sharedManager] sendLogToMainVC:@"Info: Scan for other peripherals"];
    //[self.CBCentralManager scanForPeripheralsWithServices:[PeripheryInfo sharedInstance].services options:nil];
  }
}


// Stop scan for peripheral
- (void)stopScanForPeripherals {
  
  [[Logger sharedManager] sendLogToMainVC:@"Info: Stop scanning"];

  if (self.CBCentralManager.isScanning) {
    [self.CBCentralManager stopScan];
  }
}


// Connection to the device
- (void)connectPeripheral:(AMPeripheral *)peripheral {
  
  // If the device is available and not currently connected
  if ((peripheral.CBPeripheral != nil) && (peripheral.CBPeripheral.state == CBPeripheralStateDisconnected)) {
    [self.CBCentralManager connectPeripheral:peripheral.CBPeripheral options:nil];
  }
}


// Disconnect from one of the devices
- (void)disconnectPeripheral:(AMPeripheral *)peripheral {
  
  CBPeripheral *cbPeripheral = peripheral.CBPeripheral;
  
  if ((cbPeripheral != nil) && (cbPeripheral.state == CBPeripheralStateConnecting
                                || cbPeripheral.state == CBPeripheralStateConnected)) {
    [self.CBCentralManager cancelPeripheralConnection:cbPeripheral];
  }
}


#pragma mark -
#pragma mark <CBCentralManagerDelegate>


// Update status of central manager (current device)
- (void)centralManagerDidUpdateState:(CBCentralManager *)cbCentral {
  
  switch (cbCentral.state) {
    case CBManagerStateUnknown:
    case CBManagerStateResetting:
    case CBManagerStateUnsupported:
    case CBManagerStateUnauthorized:
    {
      [[Logger sharedManager] sendLogToMainVC:@"ErrorCB: Failure to connect, remove all sessions"];
      [self.sessions removeAllObjects];
      break;
    }
      
    case CBManagerStatePoweredOff:
    {
      NSString *log = [NSString stringWithFormat:@"ErrorCB: The Bluetooth is off"];
      [[Logger sharedManager] sendLogToMainVC:log];
      break;
    }
      
    case CBManagerStatePoweredOn:
    {
      [self scanForPeripherals];
      break;
    }
  }
}


// Find all or defined peripheral devices
- (void)centralManager:(CBCentralManager *)cbCentral didDiscoverPeripheral:(CBPeripheral *)cbPeripheral advertisementData:(NSDictionary*) advertisementData RSSI:(NSNumber *)RSSI {
  
  NSLog(@"Info: CM Discover Peripheral - %@", cbPeripheral.name);
//
//  if ([cbPeripheral.name isEqual: @"Mishiko M103"]) {
//    AMPeripheral *peripheral = [[AMPeripheral alloc] initWith:cbPeripheral];
//    [self connectPeripheral:peripheral];
//  }
  //TODO: remove if condition, because we will search for certain UUID
  //if ([cbPeripheral.name isEqual: @"Mishiko M103"] || [cbPeripheral.name isEqual: @"dfdf"]) {
  //    NSLog(@"Info: CM Discover Peripheral: RSSI - %@", RSSI);
  //
  //    if (self.sessions[cbPeripheral.identifier] != nil) {
  //      BLESession *session = self.sessions[cbPeripheral.identifier];
  //
  //      if (RSSI.intValue < -70) {
  //        [self.CBCentralManager cancelPeripheralConnection:session.peripheral.CBPeripheral];
  //        return;
  //      }
  //
  //      [session.peripheral setForCanUpdateCoordinate:RSSI.integerValue];
  //      [self connectPeripheral:session.peripheral];
  //      return;
  //   // }
  //
  //    AMPeripheral *peripheral = [[AMPeripheral alloc] initWith:cbPeripheral];
  //    [peripheral setForCanUpdateCoordinate:RSSI.integerValue];
  //    BLESession *session = [[BLESession alloc] initWith:peripheral];
  //
  //    self.sessions[peripheral.CBPeripheral.identifier] = session;
  //
  //    [self connectPeripheral:peripheral];
  //  }
}


// Connection to the found device
- (void)centralManager:(CBCentralManager *)cbCentral didConnectPeripheral:(CBPeripheral *)cbPeripheral {
  
  NSString *log = [NSString stringWithFormat:@"Info: CBCentralManager did connect peripheral: %@", cbPeripheral];
  [[Logger sharedManager] sendLogToMainVC:log];

  BLESession *session = self.sessions[cbPeripheral.identifier];
  [session.peripheral didConnectAndDiscoverServices];
}


#pragma mark -
#pragma mark <CBCentralManagerDelegate> - Connection Failures


// Connect is fail
- (void)centralManager:(CBCentralManager *)cbCentral didFailToConnectPeripheral:(CBPeripheral *)cbPeripheral error:(NSError *)error {
  
  if (error != nil) {
    NSLog(@"Error: CBPeripheral did fail to connect peripheral with error: %@", error);
    return;
  }
  
  NSLog(@"Error: CBCentralManager did fail connect peripheral: %@; Error: %@", cbPeripheral, error);
  
  [self.sessions removeObjectForKey:cbPeripheral.identifier];
}


// Disconnected
- (void)centralManager:(CBCentralManager *)cbCentral didDisconnectPeripheral:(CBPeripheral *)cbPeripheral error:(NSError *)error {
  
  NSString *log = [NSString stringWithFormat:@"ErrorCB: CBCentralManager did disconnect peripheral: %@; Error: %@", cbPeripheral, error];
  [[Logger sharedManager] sendLogToMainVC:log];

  [self.CBCentralManager cancelPeripheralConnection:cbPeripheral];
  BLESession *session = self.sessions[cbPeripheral.identifier];
  [session.udpSocket closeSocket];
  [self.sessions removeObjectForKey:cbPeripheral.identifier];
  [self scanForPeripherals];
}


#pragma mark -
#pragma mark Other Methods


// Getting coordinates from Location Mahaner
- (void) getAndUpdateCoordinate {
  
  if ([LocationManager sharedManager].currentLocation) {
    CLLocationCoordinate2D coord = [LocationManager sharedManager].currentLocation.coordinate;
    
    for (CBUUID * key in self.sessions) {
      BLESession *session = [self.sessions objectForKey:key];
      NSString *strCoordinate = [NSString stringWithFormat:@"<%f : %f> Speed = %f", coord.latitude, coord.longitude, [LocationManager sharedManager].currentLocation.speed];
      [session.peripheral updateDeviceLocation:strCoordinate];
    }
  }
}


// Temporarily. For the test and retrieve information.
- (void)getAllInfo {
  for (CBUUID *  key in self.sessions) {
    BLESession *s = [self.sessions objectForKey:key];
    
    for (CBUUID *  key in s.peripheral.services) {
      AMService *value = [s.peripheral.services objectForKey:key];
      // NSLog(@"Service UUID - %@", value.Service.UUID);
      
      NSString *log = [NSString stringWithFormat:@"Service UUID - %@", value.Service.UUID];
      [[Logger sharedManager] sendLogToMainVC:log];
      
      for (CBUUID *key2 in value.characteristics) {
        
        AMCharacteristics *charVal = [value.characteristics objectForKey:key2];
        [charVal readValue];
        //NSLog(@"Val - %@, Write - %d", charVal.charValue, charVal.isWrite);
      }
    }
  }
}


- (void)testBlock:(NSString *)urlString withBlock:(void (^)(double myDoub))block
{
  block(5.7);
}
// **************************************** //

@end
