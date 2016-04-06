//
//  PQSurveyTableViewCell.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>
#import "NSObject+Basics.h"

#pragma mark - // PROTOCOLS //

@class PQSurveyTableViewCell;

@protocol PQSurveyTableViewCellDelegate <NSObject>
- (void)cellDidChangeHeight:(UITableViewCell *)sender;
- (void)cellShouldBeDeleted:(UITableViewCell *)sender;
@optional
- (void)cellDidBeginEditing:(PQSurveyTableViewCell *)sender;
- (void)cellWillChangeText:(PQSurveyTableViewCell *)sender;
- (void)cellDidChangeText:(PQSurveyTableViewCell *)sender;
- (void)cellDidEndEditing:(PQSurveyTableViewCell *)sender;
@end

#pragma mark - // DEFINITIONS (Public) //

@interface PQSurveyTableViewCell : UITableViewCell
@property (nonatomic, strong) id <PQSurveyTableViewCellDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic) CGFloat minimumHeight;
+ (NSString *)reuseIdentifier;
@end
