//
//  MainViewController.m
//  BLEClient
//
//  Created by Anton Makarov on 05.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import "MainViewController.h"
#import "CharTableViewCell.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <NSString*> *logs;

@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self selector:@selector(getLogger:) name:@"Logger" object:nil];
  
  _logs = [[NSMutableArray alloc] init];
  _tableView.delegate = self;
  _tableView.dataSource = self;
}


-(void) getLogger:(NSNotification *) notification
{
  NSDictionary *dict = notification.userInfo;
  NSString *message = [dict valueForKey:@"Log"];
 
  if (message != nil) {
    NSLog(@"%@", message);
    [_logs addObject:message];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [_tableView reloadData];
    });
  }
}


#pragma mark -
#pragma mark Button Action


- (IBAction)start:(id)sender {
  [BLECentralManager sharedManager];
  
  //[[LocationManager sharedManager] startTracking];
}


- (IBAction)stop:(id)sender {
  [[BLECentralManager sharedManager] stopScanForPeripherals];
}


- (IBAction)getAllInfo:(id)sender {
  [[BLECentralManager sharedManager] getAllInfo];
}

// Config cell
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
  
  CharTableViewCell *charCell = (CharTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"logCell"];
  charCell.log.text = [_logs objectAtIndex:indexPath.row];

  charCell.backgroundColor = [[UIColor alloc]initWithRed:183.0/255.0 green:255.0/255.0 blue:173.0/255.0 alpha:1.0];

  if ([[_logs objectAtIndex:indexPath.row] rangeOfString:@"Start"].location != NSNotFound) {
    charCell.backgroundColor = [[UIColor alloc]initWithRed:141.0/255.0 green:141.0/255.0 blue:253.0/255.0 alpha:1.0];
  } else if ([[_logs objectAtIndex:indexPath.row] rangeOfString:@"Stop"].location != NSNotFound) {
    charCell.backgroundColor = [[UIColor alloc]initWithRed:141.0/255.0 green:141.0/255.0 blue:253.0/255.0 alpha:1.0];
  } else if ([[_logs objectAtIndex:indexPath.row] rangeOfString:@"ErrorCB:"].location != NSNotFound) {
    charCell.backgroundColor = [[UIColor alloc]initWithRed:253.0/255.0 green:173.0/255.0 blue:155.0/255.0 alpha:1.0];
  } else if ([[_logs objectAtIndex:indexPath.row] rangeOfString:@"UDP:"].location != NSNotFound) {
    charCell.backgroundColor = [[UIColor alloc]initWithRed:151.0/255.0 green:237.0/255.0 blue:253.0/255.0 alpha:1.0];
  }
  
  return charCell;
}


// Number of cells
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  return [_logs count];
}


@end
