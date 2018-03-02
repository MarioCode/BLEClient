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
  
  // If bluetooth is on, start scan
  if (self.CBCentralManager.state == CBManagerStatePoweredOn) {
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    
    // nil services - searching all available devices
    [self.CBCentralManager scanForPeripheralsWithServices:nil options:options];
  }
}


// Stop scan for peripheral
- (void)stopScanForPeripherals {
  
  NSLog(@"Info: Stop scanning");
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
      NSLog(@"Error: Failure to connect");
      [self.sessions removeAllObjects];
      break;
      
    case CBManagerStatePoweredOff:
      NSLog(@"Error: The Bluetooth is off");
      break;
      
    case CBManagerStatePoweredOn:
      NSLog(@"Info: Start scanning");
      [self scanForPeripherals];
      break;
  }
}


// Find all or defined peripheral devices
- (void)centralManager:(CBCentralManager *)cbCentral didDiscoverPeripheral:(CBPeripheral *)cbPeripheral advertisementData:(NSDictionary*) advertisementData RSSI:(NSNumber *)RSSI {
  
  //TODO: remove if condition, because we will search for certain UUID
  if ([cbPeripheral.name isEqual: @"G5 SE"] || [cbPeripheral.name isEqual: @"Galaxy J2 Prime"]) {
    NSLog(@"Info: CM Discover Peripheral: RSSI - %@", RSSI);
    
    if (self.sessions[cbPeripheral.identifier] != nil) {
      BLESession *session = self.sessions[cbPeripheral.identifier];
      
      if (RSSI.intValue < -90) {
        [self.sessions removeObjectForKey:cbPeripheral.identifier];
        return;
      }
      
      [session.peripheral setForCanUpdateCoordinate:RSSI.integerValue];
      [self connectPeripheral:session.peripheral];
      return;
    }
    
    AMPeripheral *peripheral = [[AMPeripheral alloc] initWith:cbPeripheral];
    [peripheral setForCanUpdateCoordinate:RSSI.integerValue];
    BLESession *session = [[BLESession alloc] initWith:peripheral];
    
    self.sessions[peripheral.CBPeripheral.identifier] = session;
    
    [self connectPeripheral:peripheral];
  }
}


// Connection to the found device
- (void)centralManager:(CBCentralManager *)cbCentral didConnectPeripheral:(CBPeripheral *)cbPeripheral {
  
  NSLog(@"Info: CBCentralManager did connect peripheral: %@", cbPeripheral);
  
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
  
  NSLog(@"Error: CBCentralManager did disconnect peripheral: %@; Error: %@", cbPeripheral, error);
  
  BLESession *session = self.sessions[cbPeripheral.identifier];
  [session.udpSocket closeSocket];
  [self.sessions removeObjectForKey:cbPeripheral.identifier];
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
      NSLog(@"Service UUID - %@", value.Service.UUID);
      
      for (CBUUID *key2 in value.characteristics) {
        
        AMCharacteristics *charVal = [value.characteristics objectForKey:key2];
        [charVal readValue];
        NSLog(@"Val - %@, Write - %d", charVal.charValue, charVal.isWrite);
      }
    }
  }
}

// **************************************** //

@end
