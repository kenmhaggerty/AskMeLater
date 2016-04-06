//
//  PQFirebaseQuery+FQuery.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/11/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import "PQFirebaseQuery.h"

#import <Firebase/Firebase.h>

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface PQFirebaseQuery (FQuery)

+ (FQuery *)queryWithQueryItem:(PQFirebaseQuery *)queryItem andDirectory:(Firebase *)directory;
+ (FQuery *)appendQueryItem:(PQFirebaseQuery *)queryItem toQuery:(FQuery *)query;

@end
