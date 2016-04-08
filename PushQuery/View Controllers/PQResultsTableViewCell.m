//
//  PQResultsTableViewCell.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 4/7/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQResultsTableViewCell.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQResultsTableViewCell ()
@property (nonatomic, strong) IBOutlet UILabel *customTextLabel;
@property (nonatomic, strong) IBOutlet UILabel *customDetailTextLabel;
@end

@implementation PQResultsTableViewCell

#pragma mark - // SETTERS AND GETTERS //

- (UILabel *)textLabel {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return self.customTextLabel;
}

- (UILabel *)detailTextLabel {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return self.customDetailTextLabel;
}

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end
