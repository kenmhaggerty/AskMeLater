//
//  PQQuestion.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQQuestion.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "PQChoiceIndex.h"
#import "PQChoice.h"
#import "PQQuestionIndex.h"
#import "PQResponse.h"
#import "PQSurvey.h"

#import "PQCoreDataController.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQQuestion ()
@property (nullable, nonatomic, retain, readwrite) NSString *authorId;
@property (nullable, nonatomic, retain, readwrite) NSNumber *secureValue;
@property (nullable, nonatomic, retain, readwrite) NSString *surveyId;
@property (nonatomic, readwrite) BOOL willBeDeleted;
@property (nonatomic, readwrite) BOOL wasDeleted;

@property (nullable, nonatomic, retain, readwrite) NSOrderedSet <PQChoiceIndex *> *choiceIndices;
@property (nullable, nonatomic, retain, readwrite) NSSet <PQChoice *> *choiceObjects;
@property (nullable, nonatomic, retain, readwrite) PQSurvey *survey;

// OBSERVERS //

- (void)addObserversToSurvey:(PQSurvey *)survey;
- (void)removeObserversFromSurvey:(PQSurvey *)survey;
- (void)addObserversToChoice:(PQChoice *)choice;
- (void)removeObserversFromChoice:(PQChoice *)choice;
- (void)addObserversToResponse:(PQResponse *)response;
- (void)removeObserversFromResponse:(PQResponse *)response;

// RESPONDERS //

- (void)surveyIdDidChange:(NSNotification *)notification;
- (void)surveyAuthorIdDidChange:(NSNotification *)notification;
- (void)choiceWillBeDeleted:(NSNotification *)notification;
- (void)responseWillBeDeleted:(NSNotification *)notification;

// SETTERS //

- (void)setSecure:(BOOL)secure;;

// OTHER //

- (void)updateChoiceIndices;

@end

@implementation PQQuestion

#pragma mark - // SETTERS AND GETTERS //

@dynamic authorId;
@dynamic secureValue;
@dynamic surveyId;
@dynamic willBeDeleted;
@dynamic wasDeleted;

@dynamic choiceIndices;
@dynamic choiceObjects;
@dynamic survey;

- (void)setAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveAuthorId = [self primitiveValueForKey:NSStringFromSelector(@selector(authorId))];
    
    if ([AKGenerics object:authorId isEqualToObject:primitiveAuthorId]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:authorId forKey:NOTIFICATION_OBJECT_KEY];
    
    [AKGenerics postNotificationName:PQQuestionAuthorIdWillChangeNotification object:self userInfo:userInfo];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(authorId))];
    [self setPrimitiveValue:authorId forKey:NSStringFromSelector(@selector(authorId))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(authorId))];
    
    [AKGenerics postNotificationName:PQQuestionAuthorIdDidChangeNotification object:self userInfo:userInfo];
}

- (void)setQuestionId:(NSString *)questionId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveQuestionId = [self primitiveValueForKey:NSStringFromSelector(@selector(questionId))];
    
    if ([AKGenerics object:questionId isEqualToObject:primitiveQuestionId]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:questionId forKey:NOTIFICATION_OBJECT_KEY];
    
    [AKGenerics postNotificationName:PQQuestionIdWillChangeNotification object:self userInfo:userInfo];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(questionId))];
    [self setPrimitiveValue:questionId forKey:NSStringFromSelector(@selector(questionId))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(questionId))];
    
    [AKGenerics postNotificationName:PQQuestionIdDidChangeNotification object:self userInfo:userInfo];
}

- (void)setSecureValue:(NSNumber *)secureValue {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSNumber *primitiveSecureValue = [self primitiveValueForKey:NSStringFromSelector(@selector(secureValue))];
    
    if ([AKGenerics object:secureValue isEqualToObject:primitiveSecureValue]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:secureValue forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(secureValue))];
    [self setPrimitiveValue:secureValue forKey:NSStringFromSelector(@selector(secureValue))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(secureValue))];
    
    [AKGenerics postNotificationName:PQQuestionSecureDidChangeNotification object:self userInfo:userInfo];
}

- (void)setSurveyId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveSurveyId = [self primitiveValueForKey:NSStringFromSelector(@selector(surveyId))];
    
    if ([AKGenerics object:surveyId isEqualToObject:primitiveSurveyId]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:surveyId forKey:NOTIFICATION_OBJECT_KEY];
    
    [AKGenerics postNotificationName:PQQuestionSurveyIdWillChangeNotification object:self userInfo:userInfo];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(surveyId))];
    [self setPrimitiveValue:surveyId forKey:NSStringFromSelector(@selector(surveyId))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(surveyId))];
    
    [AKGenerics postNotificationName:PQQuestionSurveyIdDidChangeNotification object:self userInfo:userInfo];
}

- (void)setText:(NSString *)text {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveText = [self primitiveValueForKey:NSStringFromSelector(@selector(text))];
    
    if ([AKGenerics object:text isEqualToObject:primitiveText]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:text forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(text))];
    [self setPrimitiveValue:text forKey:NSStringFromSelector(@selector(text))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(text))];
    
    [AKGenerics postNotificationName:PQQuestionTextDidChangeNotification object:self userInfo:userInfo];
}

- (void)setChoiceIndices:(NSOrderedSet <PQChoiceIndex *> *)choiceIndices {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSOrderedSet *primitiveChoiceIndices = [self primitiveValueForKey:NSStringFromSelector(@selector(choiceIndices))];
    
    if ([AKGenerics object:choiceIndices isEqualToObject:primitiveChoiceIndices]) {
        return;
    }
    
    NSOrderedSet *primitiveChoices = self.choices;
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(choiceIndices))];
    [self setPrimitiveValue:choiceIndices forKey:NSStringFromSelector(@selector(choiceIndices))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(choiceIndices))];
    
    [self updateChoiceIndices];
    
    NSSet *primitiveSet = primitiveChoiceIndices ? primitiveChoiceIndices.set : nil;
    NSSet *set = choiceIndices ? choiceIndices.set : nil;
    if (![AKGenerics object:set isEqualToObject:primitiveSet]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[self.choices, primitiveChoices] forKeys:@[NOTIFICATION_OBJECT_KEY, NOTIFICATION_OLD_KEY]];
    [AKGenerics postNotificationName:PQQuestionChoicesWereReorderedNotification object:self userInfo:userInfo];
}

- (void)setChoiceObjects:(NSSet <PQChoice *> *)choiceObjects {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSSet <PQChoice *> *primitiveChoiceObjects = [self primitiveValueForKey:NSStringFromSelector(@selector(choiceObjects))];
    
    if ([AKGenerics object:choiceObjects isEqualToObject:primitiveChoiceObjects]) {
        return;
    }
    
    for (PQChoice *choice in primitiveChoiceObjects) {
        [self removeObserversFromChoice:choice];
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(choiceObjects))];
    [self setPrimitiveValue:choiceObjects forKey:NSStringFromSelector(@selector(choiceObjects))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(choiceObjects))];
    
    for (PQChoice *choice in choiceObjects) {
        [self addObserversToChoice:choice];
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:self.choices forKey:NOTIFICATION_OBJECT_KEY];
    [AKGenerics postNotificationName:PQQuestionChoicesDidChangeNotification object:self userInfo:userInfo];
    
    if (choiceObjects.count != primitiveChoiceObjects.count) {
        NSNumber *countValue = [NSNumber numberWithInteger:choiceObjects.count];
        userInfo = [NSDictionary dictionaryWithObject:countValue forKey:NOTIFICATION_OBJECT_KEY];
        [AKGenerics postNotificationName:PQQuestionChoicesCountDidChangeNotification object:self userInfo:userInfo];
    }
}

- (void)setResponses:(NSSet <PQResponse *> *)responses {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSSet <PQResponse *> *primitiveResponses = [self primitiveValueForKey:NSStringFromSelector(@selector(responses))];
    
    if ([AKGenerics object:responses isEqualToObject:primitiveResponses]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:responses forKey:NOTIFICATION_OBJECT_KEY];
    
    for (PQResponse *response in primitiveResponses) {
        [self removeObserversFromResponse:response];
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(responses))];
    [self setPrimitiveValue:responses forKey:NSStringFromSelector(@selector(responses))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(responses))];
    
    for (PQResponse *response in responses) {
        [self addObserversToResponse:response];
    }
    
    [AKGenerics postNotificationName:PQQuestionResponsesDidChangeNotification object:self userInfo:userInfo];
    
    if (responses.count != primitiveResponses.count) {
        NSNumber *countValue = [NSNumber numberWithInteger:responses.count];
        userInfo = [NSDictionary dictionaryWithObject:countValue forKey:NOTIFICATION_OBJECT_KEY];
        [AKGenerics postNotificationName:PQQuestionResponsesCountDidChangeNotification object:self userInfo:userInfo];
    }
}

- (void)setSurvey:(PQSurvey *)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    PQSurvey *primitiveSurvey = [self primitiveValueForKey:NSStringFromSelector(@selector(survey))];
    
    if ([AKGenerics object:survey isEqualToObject:primitiveSurvey]) {
        return;
    }
    
    BOOL surveyIsDeleted = primitiveSurvey.isDeleted;
    
    if (primitiveSurvey) {
        [self removeObserversFromSurvey:primitiveSurvey];
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(survey))];
    [self setPrimitiveValue:survey forKey:NSStringFromSelector(@selector(survey))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(survey))];
    
    if (survey) {
        [self addObserversToSurvey:survey];
    }
    
    if (!self.isDeleted && !surveyIsDeleted) {
        self.authorId = survey ? survey.authorId : nil;
        self.surveyId = survey ? survey.surveyId : nil;
    }
}

#pragma mark - // INITS AND LOADS //

- (void)dealloc {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [self teardown];
}

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
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    if (self.willBeDeleted) {
        self.willBeDeleted = NO;
        self.wasDeleted = YES;
    }
    
    if (!self.changedKeys || self.isDeleted) {
        [AKGenerics postNotificationName:PQQuestionDidSaveNotification object:self userInfo:[NSDictionary dictionaryWithNullableObject:self.changedKeys forKey:NOTIFICATION_OBJECT_KEY]];
    }
    
    if (self.changedKeys && !self.inserted) {
        NSDictionary *userInfo;
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(text))]) {
            userInfo = [NSDictionary dictionaryWithNullableObject:self.text forKey:NOTIFICATION_OBJECT_KEY];
            [AKGenerics postNotificationName:PQQuestionTextDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(secureValue))]) {
            userInfo = [NSDictionary dictionaryWithObject:self.secureValue forKey:NOTIFICATION_OBJECT_KEY];
            [AKGenerics postNotificationName:PQQuestionSecureDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(choiceIndices))]) {
            userInfo = [NSDictionary dictionaryWithNullableObject:self.choices forKey:NOTIFICATION_OBJECT_KEY];
            [AKGenerics postNotificationName:PQQuestionChoicesOrderDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(choiceObjects))]) {
            userInfo = [NSDictionary dictionaryWithNullableObject:self.choices forKey:NOTIFICATION_OBJECT_KEY];
            [AKGenerics postNotificationName:PQQuestionChoicesDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(responses))]) {
            userInfo = [NSDictionary dictionaryWithNullableObject:self.responses forKey:NOTIFICATION_OBJECT_KEY];
            [AKGenerics postNotificationName:PQQuestionResponsesDidSaveNotification object:self userInfo:userInfo];
        }
    }
    
    [super didSave];
}

- (void)prepareForDeletion {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    for (PQChoice *choice in self.choiceObjects) {
        choice.parentIsDeleted = YES;
    }
    for (PQResponse *response in self.responses) {
        response.parentIsDeleted = YES;
    }
    
    [AKGenerics postNotificationName:PQQuestionWillBeDeletedNotification object:self userInfo:nil];

    [super prepareForDeletion];
}

#pragma mark - // PUBLIC METHODS (Update) //

- (void)updateText:(NSString *)text {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    if ([AKGenerics object:text isEqualToObject:self.text]) {
        return;
    }
    
    self.text = text;
    self.editedAt = [NSDate date];
}

- (void)updateSecure:(BOOL)secure {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    if (secure == self.secure) {
        return;
    }
    
    self.secure = secure;
    self.editedAt = [NSDate date];
}

- (void)addChoice:(PQChoice *)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self insertChoice:choice atIndex:self.choiceObjects.count];
}

- (void)insertChoice:(PQChoice *)choice atIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSOrderedSet *primitiveChoices = self.choices;
    
    [self addChoiceObjectsObject:choice];
    [self insertObject:choice.choiceIndex inChoiceIndicesAtIndex:index];
    
    [self updateChoiceIndices];
    
    [self addObserversToChoice:choice];
    
    self.editedAt = [NSDate date];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[self.choices, primitiveChoices] forKeys:@[NOTIFICATION_OBJECT_KEY, NOTIFICATION_OLD_KEY]];
    [AKGenerics postNotificationName:PQQuestionChoicesWereAddedNotification object:self userInfo:userInfo];
    
    NSNumber *count = [NSNumber numberWithInteger:self.choiceObjects.count];
    userInfo = [NSDictionary dictionaryWithObject:count forKey:NOTIFICATION_OBJECT_KEY];
    [AKGenerics postNotificationName:PQQuestionChoicesCountDidChangeNotification object:self userInfo:userInfo];
}

- (void)moveChoice:(PQChoice *)choice toIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    if (![self.choices containsObject:choice]) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is not in self.%@", stringFromVariable(choice), NSStringFromSelector(@selector(choices))]];
        return;
    }
    
    [self moveChoiceAtIndex:[self.choices indexOfObject:choice] toIndex:index];
}

- (void)moveChoiceAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    if (fromIndex == toIndex) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ (%lu) and %@ (%lu) are equal", stringFromVariable(fromIndex), (unsigned long)fromIndex, stringFromVariable(toIndex), (unsigned long)toIndex]];
        return;
    }
    
    PQChoice *choice = self.choices[fromIndex];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NOTIFICATION_OBJECT_KEY] = choice;
    userInfo[NOTIFICATION_SECONDARY_KEY] = [NSNumber numberWithInteger:[self.choices indexOfObject:choice]];
    
    NSMutableOrderedSet *choices = [NSMutableOrderedSet orderedSetWithOrderedSet:self.choices];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:fromIndex];
    [choices moveObjectsAtIndexes:indexSet toIndex:toIndex];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(choices))];
    [self setPrimitiveValue:choices forKey:NSStringFromSelector(@selector(choices))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(choices))];
    
    self.editedAt = [NSDate date];
}

- (void)removeChoice:(PQChoice *)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:choice forKey:NOTIFICATION_OBJECT_KEY];
    [AKGenerics postNotificationName:PQChoiceWillBeRemovedNotification object:choice userInfo:nil];
    
    NSOrderedSet *primitiveChoices = [NSOrderedSet orderedSetWithOrderedSet:self.choices];
    
    [self removeObserversFromChoice:choice];
    
    [self removeChoiceObjectsObject:choice];
    [self removeChoiceIndicesObject:choice.choiceIndex];
    
    [self updateChoiceIndices];
    
    self.editedAt = [NSDate date];
    
    userInfo = [NSDictionary dictionaryWithObjects:@[self.choices, primitiveChoices] forKeys:@[NOTIFICATION_OBJECT_KEY, NOTIFICATION_OLD_KEY]];
    [AKGenerics postNotificationName:PQQuestionChoicesWereRemovedNotification object:self userInfo:userInfo];
    
    NSNumber *countValue = [NSNumber numberWithInteger:self.choices.count];
    userInfo = [NSDictionary dictionaryWithObject:countValue forKey:NOTIFICATION_OBJECT_KEY];
    [AKGenerics postNotificationName:PQQuestionChoicesCountDidChangeNotification object:self userInfo:userInfo];
}

- (void)removeChoiceAtIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    PQChoiceIndex *choiceIndex = [self.choiceIndices objectAtIndex:index];
    
    [self removeChoice:choiceIndex.choice];
}

#pragma mark - // PUBLIC METHODS (Getters) //

- (BOOL)secure {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return self.secureValue.boolValue;
}

- (NSOrderedSet <PQChoice *> *)choices {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableOrderedSet *choices = [NSMutableOrderedSet orderedSetWithCapacity:self.choiceIndices.count];
    PQChoiceIndex *choiceIndex;
    PQChoice *choice;
    for (int i = 0; i < self.choiceIndices.count; i++) {
        choiceIndex = self.choiceIndices[i];
        choice = choiceIndex.choice;
        [choices addObject:choice];
    }
    return [NSOrderedSet orderedSetWithOrderedSet:choices];
}

#pragma mark - // PUBLIC METHODS (Setters) //

- (void)setSecure:(BOOL)secure {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    self.secureValue = [NSNumber numberWithBool:secure];
}

- (void)setChoices:(NSOrderedSet <PQChoice *> *)choices {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableOrderedSet *choiceIndices = [NSMutableOrderedSet orderedSetWithCapacity:choices.count];
    PQChoice *choice;
    PQChoiceIndex *choiceIndex;
    for (int i = 0; i < choices.count; i++) {
        choice = choices[i];
        choiceIndex = choice.choiceIndex;
        [choiceIndices addObject:choiceIndex];
    }
    self.choiceObjects = choices.set;
    self.choiceIndices = [NSOrderedSet orderedSetWithOrderedSet:choiceIndices];
}

- (void)addResponse:(PQResponse *)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSSet *primitiveResponses = self.responses;
    
    [self addResponsesObject:response];
    
    [self addObserversToResponse:response];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[self.responses, primitiveResponses] forKeys:@[NOTIFICATION_OBJECT_KEY, NOTIFICATION_OLD_KEY]];
    [AKGenerics postNotificationName:PQQuestionResponsesWereAddedNotification object:self userInfo:userInfo];
    
    NSNumber *countValue = [NSNumber numberWithInteger:self.responses.count];
    userInfo = [NSDictionary dictionaryWithObject:countValue forKey:NOTIFICATION_OBJECT_KEY];
    [AKGenerics postNotificationName:PQQuestionResponsesCountDidChangeNotification object:self userInfo:userInfo];
}

- (void)removeResponse:(PQResponse *)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSSet *primitiveResponses = [NSSet setWithSet:self.responses];
    
    [AKGenerics postNotificationName:PQResponseWillBeRemovedNotification object:response userInfo:nil];
    
    [self removeObserversFromResponse:response];
    
    [self removeResponsesObject:response];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[self.responses, primitiveResponses] forKeys:@[NOTIFICATION_OBJECT_KEY, NOTIFICATION_OLD_KEY]];
    [AKGenerics postNotificationName:PQQuestionResponsesWereRemovedNotification object:self userInfo:userInfo];
    
    NSNumber *countValue = [NSNumber numberWithInteger:self.responses.count];
    userInfo = [NSDictionary dictionaryWithObject:countValue forKey:NOTIFICATION_OBJECT_KEY];
    [AKGenerics postNotificationName:PQQuestionResponsesCountDidChangeNotification object:self userInfo:userInfo];
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super setup];
    
    for (PQChoice *choice in self.choiceObjects) {
        [self addObserversToChoice:choice];
    }
    for (PQResponse *response in self.responses) {
        [self addObserversToResponse:response];
    }
}

- (void)teardown {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    for (PQChoice *choice in self.choiceObjects) {
        [self removeObserversFromChoice:choice];
    }
    for (PQResponse *response in self.responses) {
        [self removeObserversFromResponse:response];
    }
    
    [super teardown];
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToSurvey:(PQSurvey *)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyIdDidChange:) name:PQSurveyIdDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(surveyAuthorIdDidChange:) name:PQSurveyAuthorIdDidChangeNotification object:survey];
}

- (void)removeObserversFromSurvey:(PQSurvey *)survey {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyIdDidChangeNotification object:survey];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQSurveyAuthorIdDidChangeNotification object:survey];
}

- (void)addObserversToChoice:(PQChoice *)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(choiceWillBeDeleted:) name:PQChoiceWillBeDeletedNotification object:choice];
}

- (void)removeObserversFromChoice:(PQChoice *)choice {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQChoiceWillBeDeletedNotification object:choice];
}

- (void)addObserversToResponse:(PQResponse *)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseWillBeDeleted:) name:PQResponseWillBeDeletedNotification object:response];
}

- (void)removeObserversFromResponse:(PQResponse *)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQResponseWillBeDeletedNotification object:response];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)surveyIdDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSString *surveyId = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    self.surveyId = surveyId;
}

- (void)surveyAuthorIdDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    NSString *authorId = notification.userInfo[NOTIFICATION_OBJECT_KEY];
    
    self.authorId = authorId;
}

- (void)choiceWillBeDeleted:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQChoice *choice = notification.object;
    
    [self removeChoice:choice];
}

- (void)responseWillBeDeleted:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQResponse *response = notification.object;
    
    [self removeResponse:response];
}

#pragma mark - // PRIVATE METHODS (Other) //

- (void)updateChoiceIndices {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    for (PQChoiceIndex *choiceIndex in self.choiceIndices) {
        choiceIndex.index = [self.choiceIndices indexOfObject:choiceIndex];
    }
}

@end
