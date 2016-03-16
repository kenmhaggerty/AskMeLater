//
//  AMLSurvey+CoreDataProperties.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLSurvey+CoreDataProperties.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@implementation AMLSurvey (CoreDataProperties)

#pragma mark - // SETTERS AND GETTERS //

@dynamic name;
@dynamic createdAt;
@dynamic editedAt;
@dynamic time;
@dynamic repeat;
@dynamic enabled;
@dynamic questions;
@dynamic author;

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS //

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end
