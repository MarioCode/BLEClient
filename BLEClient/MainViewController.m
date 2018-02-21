//
//  MainViewController.m
//  BLEClient
//
//  Created by Anton Makarov on 05.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "MainViewController.h"
#import "BLECentralManager.h"
#import "AMPeripheral.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, BLEManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *deviceTable;
@property (weak, nonatomic) IBOutlet UITableView *charTable;
@property (weak, nonatomic) IBOutlet UIButton *scanAlwaysButton;
@property (weak, nonatomic) IBOutlet UIButton *scanOnceButton;
@property (weak, nonatomic) IBOutlet UIButton *writeButton;
@property (weak, nonatomic) IBOutlet UIButton *changeServiceUUID;
@property (weak, nonatomic) IBOutlet UILabel *genStringLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusOfScanning;
@property (weak, nonatomic) IBOutlet UILabel *serviceUUID;
@property (weak, nonatomic) IBOutlet UILabel *scanAllDevices;
@property (weak, nonatomic) IBOutlet UISwitch *udpSwitch;

@property (strong, nonatomic) UDPManager *udpSocket;
@property (strong, nonatomic) BLEManager *bleManager;
@property (nonatomic) BLECentralManager *centralManager;

@end


@implementation MainViewController

BOOL isSend = false;
BOOL isAllDevices = false;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _centralManager = [BLECentralManager new];
  [_centralManager scanForPeripherals];

  _udpSocket = [[UDPManager alloc] init];
  _bleManager = [BLEManager sharedInstance];
  
  _deviceTable.dataSource = self;
  _charTable.dataSource = self;
  
  _deviceTable.delegate = self;
  _charTable.delegate = self;
  _bleManager.delegate = self;
  
  [NSTimer scheduledTimerWithTimeInterval:3.0
                                   target:self
                                 selector:@selector(stop)
                                 userInfo:nil
                                  repeats:NO];
}


#pragma mark -
#pragma mark Table View


// Config cell
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
  static NSString *cellID = @"cell";
  UITableViewCell *cell;
  
  if (tableView == _deviceTable) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    
    NSString *name = [_bleManager.peripheralList  objectAtIndex:indexPath.row].name;
    if (name == nil)
      name = @"nil";
    
    cell.textLabel.text = name;
    cell.detailTextLabel.text = [_bleManager.peripheralList objectAtIndex:indexPath.row].identifier.UUIDString;
    
  } else if (tableView == _charTable) {
    CharTableViewCell *charCell = (CharTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"charCell"];
    
    //TODO: Remove CB from this controller
    CBCharacteristic *charService = [_bleManager.characteristicslList objectAtIndex:indexPath.row];
    
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
    
    NSString *stringFromData = [[NSString alloc] initWithData:[_bleManager.characteristicslList objectAtIndex:indexPath.row].value encoding:NSUTF8StringEncoding];
    
    if (_bleManager.characteristicslList.count != 0 && indexPath.row < _bleManager.characteristicslList.count)
      charCell.valueLabel.text =[@"Value: "stringByAppendingString: stringFromData];
    else
      charCell.valueLabel.text = @"Value: none";
    
    return charCell;
  }
  
  return cell;
}


// Number of cells
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  if (tableView == _deviceTable)
    return [_centralManager.peripherals count];

  if (tableView == _charTable)
    return _bleManager.characteristicslList.count;
  
  return 0;
}


#pragma mark -
#pragma mark Button Action


// Scan button action (start scanning)
- (IBAction)scanBluetoothDevices:(id)sender {
  
  if (sender == _scanOnceButton)
    [_bleManager startScanning:1 with:isAllDevices];
  else
    [_bleManager startScanning:0 with:isAllDevices];
  
  
  _statusOfScanning.text = @"Search status: scan...";
  _scanOnceButton.enabled = false;
  _scanAlwaysButton.enabled = false;
}

- (void)stop {
  [_centralManager stopScanForPeripherals];
}

// Reading data for selected characteristics
- (IBAction)readData:(id)sender {
  [_bleManager readData:[_charTable indexPathForSelectedRow].row withCharIndex:[_charTable indexPathForSelectedRow].row];
}


// Writing data for selected characteristics
- (IBAction)writeData:(id)sender {
  
  NSString *str = [self randomStringWithLength:7];
  _genStringLabel.text = str;
  [_bleManager writeData:[_charTable indexPathForSelectedRow].row withCharIndex:[_charTable indexPathForSelectedRow].row withText:str];
  
  
  [_udpSocket updateConnect:arc4random_uniform(100)+60000];
  [_udpSocket didSendData];
  
}


// Change UDP Switch
- (IBAction)updControlChange:(id)sender {
  if (_udpSwitch.isOn && [_bleManager.managerState isEqualToString:@"On"]) {
    (isSend = true);
  } else {
    isSend = false;
  }
  
  [_udpSocket didSendData];
}

- (IBAction)changeScanningMode:(id)sender {
  
  if (!isAllDevices) {
    isAllDevices = true;
    _scanAllDevices.text = @"Yes";
    _scanAllDevices.textColor = [UIColor colorWithRed:0.0 green:122/255.0 blue:1.0 alpha:1.0];
  } else {
    isAllDevices = false;
    _scanAllDevices.text = @"No";
    _scanAllDevices.textColor = [UIColor colorWithRed:241/255.0 green:9/255.0 blue:50/255.0 alpha:1.0];
  }
}

#pragma mark -
#pragma mark Helpers


// Generate random string
-(NSString *) randomStringWithLength: (int) len {
  
  NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
  
  for (int i = 0; i < len; i++) {
    [randomString appendFormat: @"%C", [letters characterAtIndex:(NSUInteger)arc4random_uniform((u_int32_t)[letters length])]];
  }
  
  return randomString;
}


#pragma mark -
#pragma mark Delegate Methods


// Change connect or scanning labels
- (void)changeStatusLabel: (NSString *)statusText withType:(NSString *)type {
  if ([type isEqualToString:@"Connect"])
    _connectStatusLabel.text = statusText;
  else if ([type isEqualToString:@"Scanning"])
    _statusOfScanning.text = statusText;
}


// Reload table data
- (void)reloadTable: (NSString *)table {
  if ([table isEqualToString:@"Devices"])
    [_deviceTable reloadData];
  
  if ([table isEqualToString:@"Characteristics"])
    [_charTable reloadData];
}


// Change label with service UUID
- (void)changeServiceUUIDLabel: (NSString *)uuidLabel {
  _serviceUUID.text = uuidLabel;
}


// Stop scanning
- (void)stopScan {
  _statusOfScanning.text = @"Search status: stop";
  _scanOnceButton.enabled = true;
  _scanAlwaysButton.enabled = true;
}

// **************************************** //

@end
