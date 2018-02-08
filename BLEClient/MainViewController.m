//
//  MainViewController.m
//  BLEClient
//
//  Created by Anton Makarov on 05.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "MainViewController.h"

#define TRACKER_SERVICE_UUID           @"0000ffe1-0000-1000-8000-00805f8b34fb"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *deviceTable;
@property (weak, nonatomic) IBOutlet UITableView *charTable;
@property (weak, nonatomic) IBOutlet UIButton *scanAlwaysButton;
@property (weak, nonatomic) IBOutlet UIButton *scanOnceButton;
@property (weak, nonatomic) IBOutlet UIButton *writeButton;
@property (weak, nonatomic) IBOutlet UIButton *stopScanButton;
@property (weak, nonatomic) IBOutlet UILabel *genStringLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusOfScanning;
@property (weak, nonatomic) IBOutlet UILabel *selectedDevice;

@end


@interface MainViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *trackerPeripheral;

@end

@implementation MainViewController

BOOL isScan = false;
NSMutableArray <CBPeripheral *> *peripheralList;
NSMutableArray <CBCharacteristic *> *characteristicslList;
NSMutableArray *charValuelList;


- (void)viewDidLoad {
  [super viewDidLoad];
  
  _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
  
  peripheralList = [[NSMutableArray alloc] init];
  characteristicslList = [[NSMutableArray alloc] init];
  charValuelList = [[NSMutableArray alloc] init];
  
  _deviceTable.dataSource = self;
  _deviceTable.delegate = self;
  _charTable.dataSource = self;
  _charTable.delegate = self;
}


//****************************************
// Table View
//****************************************


// Config cell
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
  static NSString *cellID = @"cell";
  UITableViewCell *cell;
  
  if (tableView == _deviceTable) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    
    NSString *name = [peripheralList objectAtIndex:indexPath.row].name;
    if (name == nil)
      name = @"nil";
    
    cell.textLabel.text = name;
    cell.detailTextLabel.text = [peripheralList objectAtIndex:indexPath.row].identifier.UUIDString;
    
  } else if (tableView == _charTable) {
    CharTableViewCell *charCell = (CharTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"charCell"];
    
    CBCharacteristic *charService = [characteristicslList objectAtIndex:indexPath.row];
    
    if (charService.properties & CBCharacteristicPropertyWrite)
      charCell.writeLabel.text = @"Write: +";
    else
      charCell.writeLabel.text = @"Write: -";
    
    if (charService.properties & CBCharacteristicPropertyRead)
      charCell.readLabel.text = @"Read: +";
    else
      charCell.readLabel.text = @"Read: -";
    
    if (charService.properties & CBCharacteristicPropertyNotify)
      charCell.notifyLabel.text = @"Notify: +";
    else
      charCell.notifyLabel.text = @"Notify: -";
    
    charCell.uuidLabel.text =[@"UUID: "stringByAppendingString:charService.UUID.UUIDString];
    
    if (charValuelList.count != 0 && indexPath.row != charValuelList.count)
      charCell.valueLabel.text =[@"Value: "stringByAppendingString: [charValuelList objectAtIndex:indexPath.row]];
    
    return charCell;
  }
  
  return cell;
}


// Number of cells
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  if (tableView == _deviceTable)
    return peripheralList.count;
  if (tableView == _charTable)
    return characteristicslList.count;
  
  return 0;
}


// Select table cell
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (tableView == _deviceTable) {
    [self clearData];
    
    NSString *name = [peripheralList objectAtIndex:indexPath.row].name;
    if (name == nil)
      name = @"nil";
    
    _selectedDevice.text=[@"Characteristics device: "stringByAppendingString:name];
    _trackerPeripheral = [peripheralList objectAtIndex:indexPath.row];
    _trackerPeripheral.delegate = self;
    
    NSLog(@"Connecting to peripheral %@", _trackerPeripheral.name);
    _connectStatusLabel.text=[@"Connect status: "stringByAppendingString:@"Connecting to peripheral..."];
    
    [_centralManager connectPeripheral:_trackerPeripheral options:nil];
  }
}


//****************************************
// Bluetooth Low Energy
//****************************************


// Update status of central manager (current device)
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
  
  switch (central.state) {
    case CBManagerStateUnknown:
    case CBManagerStateResetting:
    case CBManagerStateUnsupported:
    case CBManagerStateUnauthorized:
    case CBManagerStatePoweredOff:
      _statusOfScanning.text = @"Search status: BLE Off";
      NSLog(@"Error... Check Bluetooth connection.");
      break;
      
    case CBManagerStatePoweredOn:
      NSLog(@"Bluetooth is active!");
      break;
  }
}


// Connect to selected peripheral device
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
  _connectStatusLabel.text=[@"Connect status: "stringByAppendingString:@"Connected!"];
  
  NSLog(@"Connected!");
  [_trackerPeripheral discoverServices:@[[CBUUID UUIDWithString:TRACKER_SERVICE_UUID]]];
}


// Find peripheral devices and update table
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
  
  NSString *name = peripheral.name;
  if (name == nil)
    name = @"nil";
  
  if (![peripheralList containsObject:peripheral])
    [peripheralList addObject:peripheral];
  
  [_deviceTable reloadData];
}


// Discover characteristics for services
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
  
  for (CBService *service in _trackerPeripheral.services) {
    NSLog(@"Service: %@", service);
    [peripheral discoverCharacteristics:nil forService:service];
  }
}


// Characteristics for services
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
  
  if (error) {
    NSLog(@"Error");
    return;
  }
  
  for (CBCharacteristic *characteristic in service.characteristics) {
    
    if (![characteristicslList containsObject:characteristic]) {
      [characteristicslList addObject:characteristic];
    }
    
    if (characteristic.properties & CBCharacteristicPropertyRead)
      [peripheral readValueForCharacteristic:characteristic];
    
    if (characteristic.properties & CBCharacteristicPropertyNotify)
      [peripheral setNotifyValue:true forCharacteristic:characteristic];
  }
  
  [_charTable reloadData];
}


// Getting service characteristics (read)
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
  
  if (error) {
    NSLog(@"Error");
    return;
  }
  
  NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
  NSLog(@"Read data: %@", stringFromData);
  
  int count = 0;
  if (charValuelList.count == characteristicslList.count) {
    for (CBCharacteristic *charact in characteristicslList) {
      if ([charact isEqual:characteristic])
        [charValuelList replaceObjectAtIndex:count withObject:stringFromData];
      
      count++;
    }
  } else {
    [charValuelList addObject:stringFromData];
  }
  
  [_charTable reloadData];
}


// Connect is fail
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  
  _connectStatusLabel.text=[@"Connect status: "stringByAppendingString:@"Failed"];
  NSLog(@"Failed to connect");
}


// Disconnected
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  
  NSLog(@"Disconnect Peripheral");
  
  _connectStatusLabel.text=[@"Connect status: "stringByAppendingString:@"Disconnect"];
}


//****************************************
// Button Action
//****************************************


// Scan button action (start scanning)
- (IBAction)scanBluetoothDevices:(id)sender {
  isScan = true;
  
  if (isScan) {
    // Clear current data before new scanning
    [self clearData];
    
    _statusOfScanning.text = @"Search status: scan...";
    _scanOnceButton.enabled = false;
    _scanAlwaysButton.enabled = false;

    NSLog(@"Start scanning...");
    [_centralManager scanForPeripheralsWithServices:nil options:nil];
    
    // End the scan after 5 seconds
    if (sender == _scanOnceButton) {
      [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self
                                   selector:@selector(stopScanning)
                                   userInfo:nil
                                    repeats:NO];
    }
  }
}


// Reading data for selected characteristics
- (IBAction)readData:(id)sender {
  
  if (characteristicslList.count == 0)
    return;
  
  NSIndexPath *ip = [_charTable indexPathForSelectedRow];
  CBCharacteristic *ch = [characteristicslList objectAtIndex:ip.row];
  [_trackerPeripheral readValueForCharacteristic:ch];
}


// Writing data for selected characteristics
- (IBAction)writeData:(id)sender {
  
  if (characteristicslList.count == 0)
    return;
  
  NSString *str = [self randomStringWithLength:7];
  
  _genStringLabel.text = str;
  [_trackerPeripheral writeValue:[str dataUsingEncoding:NSASCIIStringEncoding]
               forCharacteristic:[characteristicslList
                                  objectAtIndex:[_charTable indexPathForSelectedRow].row]
                            type:CBCharacteristicWriteWithoutResponse];
}


// Stop always scan
- (IBAction)stopScan:(id)sender {
  [self stopScanning];
}


// Break the connection
- (IBAction)doDisconnect:(id)sender {
  
  if (_trackerPeripheral != nil) {
    [_centralManager cancelPeripheralConnection:_trackerPeripheral];
    [self clearData];
    [_charTable reloadData];
  }
}

//****************************************
// Helpers
//****************************************

// Stop scanning
- (void)stopScanning {
  isScan = false;
  _statusOfScanning.text = @"Search status: stop";
  _scanOnceButton.enabled = true;
  _scanAlwaysButton.enabled = true;
  _stopScanButton.enabled = false;

  NSLog(@"Stop");
  [_centralManager stopScan];
}


// Clearing current data
- (void) clearData {
  [charValuelList removeAllObjects];
  [characteristicslList removeAllObjects];
  [_charTable reloadData];
}

// Generate random string
-(NSString *) randomStringWithLength: (int) len {
  
  NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
  
  for (int i = 0; i < len; i++) {
    [randomString appendFormat: @"%C", [letters characterAtIndex:(NSUInteger)arc4random_uniform((u_int32_t)[letters length])]];
  }
  
  return randomString;
}

// **************************************** //

@end



