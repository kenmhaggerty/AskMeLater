//
//  AMLFirebaseQuery.m
//  AskMeLater
//
//  Created by Ken M. Haggerty on 3/11/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AMLFirebaseQuery+FQuery.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@interface AMLFirebaseQuery ()
@property (nonatomic, strong) NSString *key;
@property (nonatomic) AMLQueryRelation relation;
@property (nonatomic, strong) id value;
+ (FQuery *)appendRelation:(AMLQueryRelation)relation withValue:(id)value toQuery:(FQuery *)query;
@end

@implementation AMLFirebaseQuery

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

- (id)init {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    return [self initWithKey:nil relation:AMLKeyIsEqualTo value:nil];
}

- (id)initWithKey:(NSString *)key relation:(AMLQueryRelation)relation value:(id)value {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    self  = [super init];
    if (self) {
        _key = key;
        _relation = relation;
        _value = value;
    }
    
    return self;
}

#pragma mark - // PUBLIC METHODS (Initializers) //

+ (instancetype)queryWithKey:(NSString *)key relation:(AMLQueryRelation)relation value:(id)value {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    return [[AMLFirebaseQuery alloc] initWithKey:key relation:relation value:value];
}

#pragma mark - // CATEGORY METHODS (FQuery) //

+ (FQuery *)queryWithQueryItem:(AMLFirebaseQuery *)queryItem andDirectory:(Firebase *)directory {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:nil message:nil];
    
    FQuery *query = [directory queryOrderedByChild:queryItem.key];
    return [AMLFirebaseQuery appendRelation:queryItem.relation withValue:queryItem.value toQuery:query];
}

+ (FQuery *)appendQueryItem:(AMLFirebaseQuery *)queryItem toQuery:(FQuery *)query {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    query = [query queryOrderedByChild:queryItem.key];
    return [AMLFirebaseQuery appendRelation:queryItem.relation withValue:queryItem.value toQuery:query];
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (NSString *)description {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    NSString *relation;
    switch (self.relation) {
        case AMLKeyIsEqualTo:
            relation = @"==";
            break;
        case AMLKeyIsLessThanOrEqualTo:
            relation = @"<=";
            break;
        case AMLKeyIsGreaterThanOrEqualTo:
            relation = @">=";
            break;
    }
    return [NSString stringWithFormat:@"%@: %@ %@ %@", NSStringFromClass([self class]), self.key, relation, self.value];
}

#pragma mark - // PRIVATE METHODS //

+ (FQuery *)appendRelation:(AMLQueryRelation)relation withValue:(id)value toQuery:(FQuery *)query {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    switch (relation) {
        case AMLKeyIsEqualTo:
            return [query queryEqualToValue:value];
        case AMLKeyIsLessThanOrEqualTo:
            return [query queryStartingAtValue:value];
        case AMLKeyIsGreaterThanOrEqualTo:
            return [query queryEndingAtValue:value];
    }
}

@end
