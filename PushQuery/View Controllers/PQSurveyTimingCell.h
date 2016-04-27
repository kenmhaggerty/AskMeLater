//
//  PQSurveyTimingCell.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>
#import "NSObject+Basics.h"

#pragma mark - // PROTOCOLS //

@class PQSurveyTimingCell;

@protocol PQSurveyTimingCellDelegate <NSObject>
@optional
- (void)timingCellTimeDidChange:(PQSurveyTimingCell *)sender;
- (void)timingCellRepeatDidChange:(PQSurveyTimingCell *)sender;
- (void)timingCellEnabledDidChange:(PQSurveyTimingCell *)sender;
@end

#pragma mark - // DEFINITIONS (Public) //

@interface PQSurveyTimingCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIDatePicker *timePicker;
@property (nonatomic, strong) IBOutlet UILabel *enabledLabel;
@property (nonatomic, strong) IBOutlet UISwitch *enabledSwitch;
@property (nonatomic, strong) id <PQSurveyTimingCellDelegate> delegate;
+ (NSString *)reuseIdentifier;
- (void)setRepeatSwitch:(BOOL)on animated:(BOOL)animated;
- (BOOL)repeat;
- (void)setEnabledSwitch:(BOOL)on animated:(BOOL)animated;
- (BOOL)enabled;
@end
