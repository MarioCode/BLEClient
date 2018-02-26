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
    _peripherals = [NSMutableDictionary dictionary];
  }
  
  return self;
}


#pragma mark -
#pragma mark Methods


- (void)scanForPeripherals {
  
  // TODO: Replace nil
  NSLog(@"Info: Start scanning");
  if (self.CBCentralManager.state == CBManagerStatePoweredOn) {
    [self.peripherals removeAllObjects];
    [self.CBCentralManager scanForPeripheralsWithServices:nil options:nil];
  }
}

- (void)stopScanForPeripherals {
  
  NSLog(@"Info: Stop scanning");
  if (self.CBCentralManager.isScanning) {
    [self.CBCentralManager stopScan];
  }
}

- (void)connectPeripheral:(AMPeripheral *)peripheral {
  
  CBPeripheral *cbPeripheral = peripheral.CBPeripheral;
  
  if ((cbPeripheral != nil) && (cbPeripheral.state == CBPeripheralStateDisconnected))
    [self.CBCentralManager connectPeripheral:cbPeripheral options:nil];
}

- (void)disconnectPeripheral:(AMPeripheral *)peripheral {
  
  CBPeripheral *cbPeripheral = peripheral.CBPeripheral;
  
  if ((cbPeripheral != nil) && (cbPeripheral.state == CBPeripheralStateConnecting || cbPeripheral.state == CBPeripheralStateConnected))
    [self.CBCentralManager cancelPeripheralConnection:cbPeripheral];
}

- (void)getPeripheralInfo {

  for (CBUUID *key __strong in _peripherals) {
    AMPeripheral *value = [_peripherals objectForKey:key];
    NSLog(@"Peripheral - %@", value.CBPeripheral);
    
    [value getServiceInfo];
  }
}


#pragma mark -
#pragma mark <CBCentralManagerDelegate>


- (void)centralManagerDidUpdateState:(CBCentralManager *)cbCentral {
  NSLog(@"Info: CBCentralManager did update state: %ld", (long)cbCentral.state);
  
  switch (cbCentral.state) {
    case CBManagerStateUnknown:
    case CBManagerStateResetting:
    case CBManagerStateUnsupported:
    case CBManagerStateUnauthorized:
      [self.peripherals removeAllObjects];
      break;
      
    case CBManagerStatePoweredOff:
      break;
      
    case CBManagerStatePoweredOn:
      [self scanForPeripherals];
      break;
  }
}

- (void)centralManager:(CBCentralManager *)cbCentral didDiscoverPeripheral:(CBPeripheral *)cbPeripheral advertisementData:(NSDictionary*) advertisementData RSSI:(NSNumber *)RSSI {

  if ([cbPeripheral.name isEqual: @"G5 SE"] || [cbPeripheral.name isEqual: @"Galaxy J2 Prime"]) {
    NSLog(@"Info: CM Discover Peripheral: %@", cbPeripheral);
    
    AMPeripheral *peripheral = [AMPeripheral peripheralWithCBPeripheral:cbPeripheral];
    self.peripherals[peripheral.CBPeripheral.identifier] = peripheral;
    [self connectPeripheral:peripheral];
  }
}

- (void)centralManager:(CBCentralManager *)cbCentral didConnectPeripheral:(CBPeripheral *)cbPeripheral {
  NSLog(@"Info: CBCentralManager did connect peripheral: %@", cbPeripheral);
  
  AMPeripheral *peripheral = self.peripherals[cbPeripheral.identifier];
  [peripheral didConnect];
}


#pragma mark -
#pragma mark <CBCentralManagerDelegate> - Connection Failures


- (void)centralManager:(CBCentralManager *)cbCentral didFailToConnectPeripheral:(CBPeripheral *)cbPeripheral error:(NSError *)error {
  NSLog(@"Error: CBCentralManager did fail connect peripheral: %@; Error: %@", cbPeripheral, error);
  
  AMPeripheral *peripheral = self.peripherals[cbPeripheral.identifier];
  [peripheral didFailToConnectWithError:error];
}

- (void)centralManager:(CBCentralManager *)cbCentral didDisconnectPeripheral:(CBPeripheral *)cbPeripheral error:(NSError *)error {
  NSLog(@"Info: CBCentralManager did disconnect peripheral: %@; Error: %@", cbPeripheral, error);
  
  AMPeripheral *peripheral = self.peripherals[cbPeripheral.identifier];
  [peripheral didDisconnectWithError:error];
  [self scanForPeripherals];
}


#pragma mark -
#pragma mark <UdpToBleBridgeDelegate>


- (void)didSendData: (NSData *)data toPort:(NSInteger)port {
  
  for (CBUUID *key __strong in _peripherals) {
    AMPeripheral *value = [_peripherals objectForKey:key];
    
    if (value.udpPort == port) {
      [value sendRequestData: data];
      return;
    }
  }
}


// **************************************** //

@end
