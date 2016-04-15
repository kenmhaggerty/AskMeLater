//
//  PQTableViewCell.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 4/7/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>
#import "NSObject+Basics.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface PQTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *subtitleTextLabel;
@end
