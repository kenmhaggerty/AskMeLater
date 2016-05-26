//
//  PQSyncedObject.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/9/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQSyncedObject.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQSyncedObject ()
@end

@implementation PQSyncedObject

#pragma mark - // SETTERS AND GETTERS //

@synthesize isDownloaded = _isDownloaded;

#pragma mark - // INITS AND LOADS //

- (void)awakeFromInsert {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super awakeFromInsert];
    
    [self setup];
}

- (void)awakeFromFetch {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super awakeFromFetch];
    
    [self setup];
}

- (void)didSave {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    self.isDownloaded = NO;
    
    [super didSave];
}

#pragma mark - // PUBLIC METHODS //

- (void)setIsDownloaded:(BOOL)isDownloaded {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_DATA] message:nil];
    
    _isDownloaded = isDownloaded;
    self.isUploadedValue = [NSNumber numberWithBool:isDownloaded];
}

- (BOOL)isUploaded {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_DATA] message:nil];
    
    return self.isUploadedValue.boolValue;
}

- (void)setIsUploaded:(BOOL)isUploaded {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_DATA] message:nil];
    
    self.isUploadedValue = [NSNumber numberWithBool:isUploaded];
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super setup];
    
    self.isDownloaded = NO;
}

#pragma mark - // PRIVATE METHODS //

@end
