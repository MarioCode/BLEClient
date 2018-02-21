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
    _peripheryInfo = [PeripheryInfo sharedInstance];
    dispatch_queue_t queue = dispatch_queue_create("CentralManagerQueue", DISPATCH_QUEUE_SERIAL);
    NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey: @YES,
                              CBCentralManagerOptionRestoreIdentifierKey: @""};
    
    _CBCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:options];
    _peripherals = [NSMutableDictionary dictionary];
  }
  
  return self;
}


#pragma mark -
#pragma mark Methods


- (void)scanForPeripherals {
  
  if (self.CBCentralManager.state == CBManagerStatePoweredOn) {
    
    dispatch_sync(dispatch_get_main_queue(), ^(void) { [self willChangeValueForKey:@"peripherals"]; });
    [self.peripherals removeAllObjects];
    dispatch_sync(dispatch_get_main_queue(), ^(void) { [self didChangeValueForKey:@"peripherals"]; });
    
    NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey: @YES,
                              CBCentralManagerScanOptionSolicitedServiceUUIDsKey: @[]};
    
    // TODO: Replace nil
    [self.CBCentralManager scanForPeripheralsWithServices:nil options:options];
    
  }
}

- (void)stopScanForPeripherals {
  
  NSLog(@"Stop scanning");
  if (self.CBCentralManager.isScanning) {
    [self.CBCentralManager stopScan];
  }
}

- (void)connectPeripheral:(AMPeripheral *)peripheral {
  
  CBPeripheral *cbPeripheral = peripheral.CBPeripheral;
  
  if ((cbPeripheral != nil) && (cbPeripheral.state == CBPeripheralStateDisconnected)) {
    NSDictionary *options = @{CBConnectPeripheralOptionNotifyOnConnectionKey: @YES,
                              CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES,
                              CBConnectPeripheralOptionNotifyOnNotificationKey: @YES};
    
    [self.CBCentralManager connectPeripheral:cbPeripheral options:options];
  }
}

- (void)disconnectPeripheral:(AMPeripheral *)peripheral {
  
  CBPeripheral *cbPeripheral = peripheral.CBPeripheral;
  
  if ((cbPeripheral != nil) && (cbPeripheral.state == CBPeripheralStateConnecting || cbPeripheral.state == CBPeripheralStateConnected))
    [self.CBCentralManager cancelPeripheralConnection:cbPeripheral];
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
    {
      dispatch_sync(dispatch_get_main_queue(), ^(void) { [self willChangeValueForKey:@"peripherals"]; });
      [self.peripherals removeAllObjects];
      dispatch_sync(dispatch_get_main_queue(), ^(void) { [self didChangeValueForKey:@"peripherals"]; });
      
      break;
    }
    case CBManagerStatePoweredOff:
      break;
    case CBManagerStatePoweredOn:
    {
      [self scanForPeripherals];
      break;
    }
    default:
      break;
  }
}

- (void)centralManager:(CBCentralManager *)cbCentral didDiscoverPeripheral:(CBPeripheral *)cbPeripheral advertisementData:(NSDictionary*) advertisementData RSSI:(NSNumber *)RSSI {
  
  AMPeripheral *peripheral = self.peripherals[cbPeripheral.identifier];

  if (peripheral == nil && ([cbPeripheral.name isEqual: @"G5 SE"] || [cbPeripheral.name isEqual: @"Galaxy J2 Prime"])) {
    NSLog(@"Info: CM Discover Peripheral: %@", cbPeripheral);
    
    peripheral = [AMPeripheral peripheralWithCBPeripheral:cbPeripheral];
    
    dispatch_sync(dispatch_get_main_queue(), ^(void) { [self willChangeValueForKey:@"peripherals"]; });
    self.peripherals[peripheral.CBPeripheral.identifier] = peripheral;
    dispatch_sync(dispatch_get_main_queue(), ^(void) { [self didChangeValueForKey:@"peripherals"]; });
    
    [self connectPeripheral:peripheral];
  }
}

- (void)centralManager:(CBCentralManager *)cbCentral didConnectPeripheral:(CBPeripheral *)cbPeripheral {
  NSLog(@"Info: CBCentralManager did connect peripheral: %@", cbPeripheral);
  
  AMPeripheral *peripheral = self.peripherals[cbPeripheral.identifier];
  [peripheral didConnect];
}

- (void)peripheral:(CBPeripheral *)cbPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)cbCharacteristic error:(NSError *)error {
  NSLog(@"Error: CBPeripheral did update value for characteristic: %@; Error: %@", cbCharacteristic, error);
  
  //AMService *service = self.services[cbCharacteristic.service.UUID];
  //AMCharacteristics *characteristic = service.characteristics[cbCharacteristic.UUID];
  //[characteristic didUpdateValueWithError:error];
}

- (void)peripheral:(CBPeripheral *)cbPeripheral didWriteValueForCharacteristic:(CBCharacteristic *)cbCharacteristic error:(NSError *)error {
  NSLog(@"Info: CBPeripheral did write value for characteristic: %@; Error: %@", cbCharacteristic, error);

}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)cbCharacteristic error:(NSError *)error {
  NSLog(@"Info: CBPeripheral did update notification state for characteristic: %@; Error: %@", cbCharacteristic, error);

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

- (void)centralManager:(CBCentralManager *)cbCentral willRestoreState:(NSDictionary *)dict {
  NSLog(@"Info: CBCentralManager will restore state: %@", dict);
}

// **************************************** //

@end
