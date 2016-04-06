//
//  PQFirebaseQuery.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/11/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQFirebaseQuery+FQuery.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQFirebaseQuery ()
@property (nonatomic, strong) NSString *key;
@property (nonatomic) PQQueryRelation relation;
@property (nonatomic, strong) id value;
+ (FQuery *)appendRelation:(PQQueryRelation)relation withValue:(id)value toQuery:(FQuery *)query;
@end

@implementation PQFirebaseQuery

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

- (id)init {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    return [self initWithKey:nil relation:PQKeyIsEqualTo value:nil];
}

- (id)initWithKey:(NSString *)key relation:(PQQueryRelation)relation value:(id)value {
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

+ (instancetype)queryWithKey:(NSString *)key relation:(PQQueryRelation)relation value:(id)value {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    return [[PQFirebaseQuery alloc] initWithKey:key relation:relation value:value];
}

#pragma mark - // CATEGORY METHODS (FQuery) //

+ (FQuery *)queryWithQueryItem:(PQFirebaseQuery *)queryItem andDirectory:(Firebase *)directory {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator tags:nil message:nil];
    
    FQuery *query = [directory queryOrderedByChild:queryItem.key];
    return [PQFirebaseQuery appendRelation:queryItem.relation withValue:queryItem.value toQuery:query];
}

+ (FQuery *)appendQueryItem:(PQFirebaseQuery *)queryItem toQuery:(FQuery *)query {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    query = [query queryOrderedByChild:queryItem.key];
    return [PQFirebaseQuery appendRelation:queryItem.relation withValue:queryItem.value toQuery:query];
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (NSString *)description {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    NSString *relation;
    switch (self.relation) {
        case PQKeyIsEqualTo:
            relation = @"==";
            break;
        case PQKeyIsLessThanOrEqualTo:
            relation = @"<=";
            break;
        case PQKeyIsGreaterThanOrEqualTo:
            relation = @">=";
            break;
    }
    return [NSString stringWithFormat:@"%@: %@ %@ %@", NSStringFromClass([self class]), self.key, relation, self.value];
}

#pragma mark - // PRIVATE METHODS //

+ (FQuery *)appendRelation:(PQQueryRelation)relation withValue:(id)value toQuery:(FQuery *)query {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    switch (relation) {
        case PQKeyIsEqualTo:
            return [query queryEqualToValue:value];
        case PQKeyIsLessThanOrEqualTo:
            return [query queryStartingAtValue:value];
        case PQKeyIsGreaterThanOrEqualTo:
            return [query queryEndingAtValue:value];
    }
}

@end
