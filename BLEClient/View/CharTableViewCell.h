//
//  CharTableViewCell.h
//  BLEClient
//
//  Created by Anton Makarov on 07.02.2018.
//  Copyright © 2018 Anton Makarov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CharTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *readLabel;
@property (weak, nonatomic) IBOutlet UILabel *writeLabel;
@property (weak, nonatomic) IBOutlet UILabel *notifyLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;

@end
