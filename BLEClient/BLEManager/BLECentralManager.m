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
- (void)startScanForPeripherals {
  
  NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
  [[Logger sharedManager] sendLogToMainVC:@"Info: Start scan without dublicate"];
  [self checkExistDevice];
  [self.CBCentralManager scanForPeripheralsWithServices:nil options:options];
}


// Check and connect to exist device on list
- (void)checkExistDevice {
  
  if (self.CBCentralManager.state != CBManagerStatePoweredOn) {
    return;
  }
    
  NSArray <CBPeripheral*> *per = [self.CBCentralManager retrieveConnectedPeripheralsWithServices:[PeripheryInfo sharedInstance].services];
    
  if (per.count == 0) {
    return;
  }
  
  [[Logger sharedManager] sendLogToMainVC:@"Info: Connection to existing connected devices"];
  for (int i = 0; i < per.count; i++) {
    if (self.sessions[per[i].identifier] != nil) {
      continue;
    }
    
    AMPeripheral *peripheral = [[AMPeripheral alloc] initWith:per[i]];
    BLESession *session = [[BLESession alloc] initWith:peripheral];
    self.sessions[peripheral.CBPeripheral.identifier] = session;
    [self connectPeripheral:peripheral];
  }
}


// Check and connect to exist session
- (void)checkExistSessions {
  
  if (self.CBCentralManager.state != CBManagerStatePoweredOn) {
    return;
  }
  
  if (self.sessions.count == 0) {
    return;
  }
  
  for (CBUUID *key in self.sessions) {
    BLESession *s = [self.sessions objectForKey:key];
    if (![s.peripheral isConnected]) {
        
      NSString *log = [NSString stringWithFormat:@"Info: Reconnection to existing session: Peripheral - %@, UDP - %@", s.peripheral.CBPeripheral, s.udpSocket];
      [[Logger sharedManager] sendLogToMainVC:log];
      [self.CBCentralManager connectPeripheral:s.peripheral.CBPeripheral options:nil];
    }
  }
}

- (void)reConnect {
  [self checkExistSessions];
  [self checkExistDevice];
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
      [self.sessions removeAllObjects];
      [self.CBCentralManager stopScan];
      break;
    }
      
    case CBManagerStatePoweredOn:
    {
      [self startScanForPeripherals];
      break;
    }
  }
}


// Find all or defined peripheral devices
- (void)centralManager:(CBCentralManager *)cbCentral didDiscoverPeripheral:(CBPeripheral *)cbPeripheral advertisementData:(NSDictionary*) advertisementData RSSI:(NSNumber *)RSSI {
  
  if ([cbPeripheral.name isEqual: [PeripheryInfo sharedInstance].deviceName]) {
    if (self.sessions[cbPeripheral.identifier] == nil) {
      AMPeripheral *peripheral = [[AMPeripheral alloc] initWith:cbPeripheral];
      BLESession *session = [[BLESession alloc] initWith:peripheral];
      [session.peripheral setForCanUpdateCoordinate:RSSI.integerValue];
      self.sessions[peripheral.CBPeripheral.identifier] = session;
      [self connectPeripheral:peripheral];
      return;
    }
  }
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
  [LocationManager.sharedManager stopTracking];
  [self.CBCentralManager cancelPeripheralConnection:cbPeripheral];
  BLESession *session = self.sessions[cbPeripheral.identifier];
  [session.udpSocket closeSocket];
  [self.sessions removeObjectForKey:cbPeripheral.identifier];
  [self reConnect];
}


#pragma mark -
#pragma mark Other Methods


// Getting coordinates from Location Mahaner
- (void) getAndUpdateCoordinate {
  
  if ([LocationManager sharedManager].currentLocation) {
    for (CBUUID * key in self.sessions) {
      BLESession *session = [self.sessions objectForKey:key];
      [session.peripheral updateDeviceLocation:[LocationManager sharedManager].currentLocation];
    }
  }
}


- (void)testBlock:(NSString *)urlString withBlock:(void (^)(double myDoub))block
{
  block(5.7);
}
// **************************************** //

@end
