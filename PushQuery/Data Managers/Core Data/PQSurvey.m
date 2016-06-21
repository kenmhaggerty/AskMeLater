//
//  PQSurvey.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 3/16/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "PQSurvey.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

#import "PQUser.h"
#import "PQQuestionIndex.h"
#import "PQQuestion.h"

#import "PQCoreDataController.h"

#pragma mark - // DEFINITIONS (Private) //

@interface PQSurvey ()
@property (nullable, nonatomic, retain, readwrite) NSNumber *enabledValue;
@property (nullable, nonatomic, retain, readwrite) NSNumber *repeatValue;
@property (nonatomic, readwrite) BOOL willBeDeleted;
@property (nonatomic, readwrite) BOOL wasDeleted;
@property (nonatomic, strong) NSNumber *canBeEnabledValue;

@property (nullable, nonatomic, retain, readwrite) PQUser *author;
@property (nullable, nonatomic, retain, readwrite) NSOrderedSet <PQQuestionIndex *> *questionIndices;
@property (nullable, nonatomic, retain, readwrite) NSSet <PQQuestion *> *questionObjects;

// OBSERVERS //

- (void)addObserversToQuestion:(PQQuestion *)question;
- (void)removeObserversFromQuestion:(PQQuestion *)question;

// RESPONDERS //

- (void)questionIdDidChange:(NSNotification *)notification;
- (void)questionTextDidChange:(NSNotification *)notification;
- (void)questionWillBeDeleted:(NSNotification *)notification;

// OTHER //

- (void)updateQuestionIndices;

@end

@implementation PQSurvey

#pragma mark - // SETTERS AND GETTERS //

@dynamic enabledValue;
@dynamic repeatValue;
@dynamic willBeDeleted;
@dynamic wasDeleted;
@synthesize canBeEnabledValue = _canBeEnabledValue;

@dynamic author;
@dynamic questionIndices;
@dynamic questionObjects;

- (void)setAuthorId:(NSString *)authorId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveAuthorId = [self primitiveValueForKey:NSStringFromSelector(@selector(authorId))];
    
    if ([AKGenerics object:authorId isEqualToObject:primitiveAuthorId]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:authorId forKey:NOTIFICATION_OBJECT_KEY];
    
    [NSNotificationCenter postNotificationToMainThread:PQSurveyAuthorIdWillChangeNotification object:self userInfo:userInfo];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(authorId))];
    [self setPrimitiveValue:authorId forKey:NSStringFromSelector(@selector(authorId))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(authorId))];
    
    [NSNotificationCenter postNotificationToMainThread:PQSurveyAuthorIdDidChangeNotification object:self userInfo:userInfo];
    
    self.author = authorId ? [PQCoreDataController getUserWithId:self.authorId] : nil;
}

- (void)setEditedAt:(NSDate *)editedAt {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    if (!editedAt) {
        //
    }
    
    NSString *primitiveEditedAt = [self primitiveValueForKey:NSStringFromSelector(@selector(editedAt))];
    
    if ([AKGenerics object:editedAt isEqualToObject:primitiveEditedAt]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:editedAt forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(editedAt))];
    [self setPrimitiveValue:editedAt forKey:NSStringFromSelector(@selector(editedAt))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(editedAt))];
    
    [NSNotificationCenter postNotificationToMainThread:PQSurveyEditedAtDidChangeNotification object:self userInfo:userInfo];
}

- (void)setEnabledValue:(NSNumber *)enabledValue {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSNumber *primitiveEnabledValue = [self primitiveValueForKey:NSStringFromSelector(@selector(enabledValue))];
    
    if ([AKGenerics object:enabledValue isEqualToObject:primitiveEnabledValue]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:enabledValue forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(enabledValue))];
    [self setPrimitiveValue:enabledValue forKey:NSStringFromSelector(@selector(enabledValue))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(enabledValue))];
    
    [NSNotificationCenter postNotificationToMainThread:PQSurveyEnabledDidChangeNotification object:self userInfo:userInfo];
}

- (void)setName:(NSString *)name {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveName = [self primitiveValueForKey:NSStringFromSelector(@selector(name))];
    
    if ([AKGenerics object:name isEqualToObject:primitiveName]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:name forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(name))];
    [self setPrimitiveValue:name forKey:NSStringFromSelector(@selector(name))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(name))];
    
    [NSNotificationCenter postNotificationToMainThread:PQSurveyNameDidChangeNotification object:self userInfo:userInfo];
}

- (void)setRepeatValue:(NSNumber *)repeatValue {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSNumber *primitiveRepeatValue = [self primitiveValueForKey:NSStringFromSelector(@selector(repeatValue))];
    
    if ([AKGenerics object:repeatValue isEqualToObject:primitiveRepeatValue]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:repeatValue forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(repeatValue))];
    [self setPrimitiveValue:repeatValue forKey:NSStringFromSelector(@selector(repeatValue))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(repeatValue))];
    
    [NSNotificationCenter postNotificationToMainThread:PQSurveyRepeatDidChangeNotification object:self userInfo:userInfo];
}

- (void)setSurveyId:(NSString *)surveyId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSString *primitiveSurveyId = [self primitiveValueForKey:NSStringFromSelector(@selector(surveyId))];
    
    if ([AKGenerics object:surveyId isEqualToObject:primitiveSurveyId]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:surveyId forKey:NOTIFICATION_OBJECT_KEY];
    
    [NSNotificationCenter postNotificationToMainThread:PQSurveyIdWillChangeNotification object:self userInfo:userInfo];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(surveyId))];
    [self setPrimitiveValue:surveyId forKey:NSStringFromSelector(@selector(surveyId))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(surveyId))];
    
    [NSNotificationCenter postNotificationToMainThread:PQSurveyIdDidChangeNotification object:self userInfo:userInfo];
    
    self.canBeEnabledValue = [NSNumber numberWithBool:self.canBeEnabled];
}

- (void)setTime:(NSDate *)time {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSDate *roundedTime = [time dateRoundedToPrecision:6];
    
    NSDate *primitiveTime = [self primitiveValueForKey:NSStringFromSelector(@selector(time))];
    
    if ([AKGenerics object:roundedTime isEqualToObject:primitiveTime]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:roundedTime forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(time))];
    [self setPrimitiveValue:roundedTime forKey:NSStringFromSelector(@selector(time))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(time))];
    
    [NSNotificationCenter postNotificationToMainThread:PQSurveyTimeDidChangeNotification object:self userInfo:userInfo];
    
    self.canBeEnabledValue = [NSNumber numberWithBool:self.canBeEnabled];
}

- (void)setAuthor:(PQUser *)author {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    PQQuestion *primitiveAuthor = [self primitiveValueForKey:NSStringFromSelector(@selector(author))];
    
    if ([AKGenerics object:author isEqualToObject:primitiveAuthor]) {
        return;
    }
    
    BOOL authorIsDeleted = primitiveAuthor.isDeleted;
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:author forKey:NOTIFICATION_OBJECT_KEY];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(author))];
    [self setPrimitiveValue:author forKey:NSStringFromSelector(@selector(author))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(author))];
    
    if (!self.isDeleted && !authorIsDeleted) {
        self.authorId = author ? author.userId : nil;
    }
    
    [NSNotificationCenter postNotificationToMainThread:PQSurveyAuthorDidChangeNotification object:self userInfo:userInfo];
}

- (void)setQuestionIndices:(NSOrderedSet <PQQuestionIndex *> *)questionIndices {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSOrderedSet *primitiveQuestionIndices = [self primitiveValueForKey:NSStringFromSelector(@selector(questionIndices))];
    
    if ([AKGenerics object:questionIndices isEqualToObject:primitiveQuestionIndices]) {
        return;
    }
    
    NSOrderedSet *primitiveQuestions = self.questions;
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(questionIndices))];
    [self setPrimitiveValue:questionIndices forKey:NSStringFromSelector(@selector(questionIndices))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(questionIndices))];
    
    [self updateQuestionIndices];
    
    NSSet *primitiveSet = primitiveQuestionIndices ? primitiveQuestionIndices.set : nil;
    NSSet *set = questionIndices ? questionIndices.set : nil;
    if (![AKGenerics object:set isEqualToObject:primitiveSet]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[self.questions, primitiveQuestions] forKeys:@[NOTIFICATION_OBJECT_KEY, NOTIFICATION_OLD_KEY]];
    [NSNotificationCenter postNotificationToMainThread:PQSurveyQuestionsWereReorderedNotification object:self userInfo:userInfo];
}

- (void)setQuestionObjects:(NSSet <PQQuestion *> *)questionObjects {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSSet *primitiveQuestionObjects = [self primitiveValueForKey:NSStringFromSelector(@selector(questionObjects))];
    
    if ([AKGenerics object:questionObjects isEqualToObject:primitiveQuestionObjects]) {
        return;
    }
    
    for (PQQuestion *question in primitiveQuestionObjects) {
        [self removeObserversFromQuestion:question];
    }
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(questionObjects))];
    [self setPrimitiveValue:questionObjects forKey:NSStringFromSelector(@selector(questionObjects))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(questionObjects))];
    
    for (PQQuestion *question in questionObjects) {
        [self addObserversToQuestion:question];
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:self.questions forKey:NOTIFICATION_OBJECT_KEY];
    [NSNotificationCenter postNotificationToMainThread:PQSurveyQuestionsDidChangeNotification object:self userInfo:userInfo];
    
    if (questionObjects.count != primitiveQuestionObjects.count) {
        NSNumber *countValue = [NSNumber numberWithInteger:questionObjects.count];
        userInfo = [NSDictionary dictionaryWithObject:countValue forKey:NOTIFICATION_OBJECT_KEY];
        [NSNotificationCenter postNotificationToMainThread:PQSurveyQuestionsCountDidChangeNotification object:self userInfo:userInfo];
    }
    
    self.canBeEnabledValue = [NSNumber numberWithBool:self.canBeEnabled];
}

- (void)setCanBeEnabledValue:(NSNumber *)canBeEnabledValue {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_DATA] message:nil];
    
    if ([AKGenerics object:canBeEnabledValue isEqualToObject:_canBeEnabledValue]) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:canBeEnabledValue forKey:NOTIFICATION_OBJECT_KEY];
    
    _canBeEnabledValue = canBeEnabledValue;
    
    if (!canBeEnabledValue.boolValue) {
        self.enabledValue = @NO;
    }
    
    [NSNotificationCenter postNotificationToMainThread:PQSurveyCanBeEnabledDidChangeNotification object:self userInfo:userInfo];
}

- (NSNumber *)canBeEnabledValue {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_DATA] message:nil];
    
    NSNumber *canBeEnabledValue = [self primitiveValueForKey:NSStringFromSelector(@selector(canBeEnabledValue))];
    
    return canBeEnabledValue ?: [NSNumber numberWithBool:self.canBeEnabled];
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
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    if (self.willBeDeleted) {
        self.willBeDeleted = NO;
        self.wasDeleted = YES;
    }
    
    if (!self.changedKeys || self.isDeleted) {
        [NSNotificationCenter postNotificationToMainThread:PQSurveyDidSaveNotification object:self userInfo:[NSDictionary dictionaryWithNullableObject:self.changedKeys forKey:NOTIFICATION_OBJECT_KEY]];
    }
    
    if (self.changedKeys && !self.inserted) {
        NSDictionary *userInfo;
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(editedAt))]) {
            userInfo = [NSDictionary dictionaryWithObject:self.editedAt forKey:NOTIFICATION_OBJECT_KEY];
            [NSNotificationCenter postNotificationToMainThread:PQSurveyEditedAtDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(enabledValue))]) {
            userInfo = [NSDictionary dictionaryWithObject:self.enabledValue forKey:NOTIFICATION_OBJECT_KEY];
            [NSNotificationCenter postNotificationToMainThread:PQSurveyEnabledDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(name))]) {
            userInfo = [NSDictionary dictionaryWithNullableObject:self.name forKey:NOTIFICATION_OBJECT_KEY];
            [NSNotificationCenter postNotificationToMainThread:PQSurveyNameDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(repeatValue))]) {
            userInfo = [NSDictionary dictionaryWithObject:self.repeatValue forKey:NOTIFICATION_OBJECT_KEY];
            [NSNotificationCenter postNotificationToMainThread:PQSurveyRepeatDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(time))]) {
            userInfo = [NSDictionary dictionaryWithNullableObject:self.time forKey:NOTIFICATION_OBJECT_KEY];
            [NSNotificationCenter postNotificationToMainThread:PQSurveyTimeDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(author))]) {
            userInfo = [NSDictionary dictionaryWithNullableObject:self.author forKey:NOTIFICATION_OBJECT_KEY];
            [NSNotificationCenter postNotificationToMainThread:PQSurveyAuthorDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(questionIndices))]) {
            userInfo = [NSDictionary dictionaryWithObject:self.questions forKey:NOTIFICATION_OBJECT_KEY];
            [NSNotificationCenter postNotificationToMainThread:PQSurveyQuestionsOrderDidSaveNotification object:self userInfo:userInfo];
        }
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(questionObjects))]) {
            userInfo = [NSDictionary dictionaryWithObject:self.questions forKey:NOTIFICATION_OBJECT_KEY];
            [NSNotificationCenter postNotificationToMainThread:PQSurveyQuestionsDidSaveNotification object:self userInfo:userInfo];
        }
    }
    
    [super didSave];
}

- (void)prepareForDeletion {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    for (PQQuestion *question in self.questionObjects) {
        question.parentIsDeleted = YES;
    }
    
    [NSNotificationCenter postNotificationToMainThread:PQSurveyWillBeDeletedNotification object:self userInfo:nil];
    
    [super prepareForDeletion];
}

#pragma mark - // PUBLIC METHODS (Update) //

- (void)updateEnabled:(BOOL)enabled {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    if (enabled == self.enabled) {
        return;
    }
    
    self.enabled = enabled;
    self.editedAt = [NSDate date];
}

- (void)updateName:(NSString *)name {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    if ([AKGenerics object:name isEqualToObject:self.name]) {
        return;
    }
    
    self.name = name;
    self.editedAt = [NSDate date];
}

- (void)updateRepeat:(BOOL)repeat {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    if (repeat == self.repeat) {
        return;
    }
    
    self.repeat = repeat;
    self.editedAt = [NSDate date];
}

- (void)updateTime:(NSDate *)time {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    if ([AKGenerics object:time isEqualToObject:self.time]) {
        return;
    }
    
    self.time = time;
    self.editedAt = [NSDate date];
}

- (void)addQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self insertQuestion:question atIndex:self.questionObjects.count];
}

- (void)insertQuestion:(PQQuestion *)question atIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSOrderedSet *primitiveQuestions = self.questions;
    
    [self addQuestionObjectsObject:question];
    [self insertObject:question.questionIndex inQuestionIndicesAtIndex:index];
    
    [self updateQuestionIndices];
    
    [self addObserversToQuestion:question];
    
    self.editedAt = [NSDate date];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[self.questions, primitiveQuestions] forKeys:@[NOTIFICATION_OBJECT_KEY, NOTIFICATION_OLD_KEY]];
    [NSNotificationCenter postNotificationToMainThread:PQSurveyQuestionsWereAddedNotification object:self userInfo:userInfo];
    
    NSNumber *count = [NSNumber numberWithInteger:self.questionObjects.count];
    userInfo = [NSDictionary dictionaryWithObject:count forKey:NOTIFICATION_OBJECT_KEY];
    [NSNotificationCenter postNotificationToMainThread:PQSurveyQuestionsCountDidChangeNotification object:self userInfo:userInfo];
    
    self.canBeEnabledValue = [NSNumber numberWithBool:self.canBeEnabled];
}

- (void)moveQuestion:(PQQuestion *)question toIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    [self moveQuestionAtIndex:[self.questionIndices indexOfObject:question.questionIndex] toIndex:index];
}

- (void)moveQuestionAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    if (toIndex == fromIndex) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ (%lu) and %@ (%lu) are equal", stringFromVariable(fromIndex), (unsigned long)fromIndex, stringFromVariable(toIndex), (unsigned long)toIndex]];
        return;
    }
    
    NSMutableOrderedSet *questionIndices = [NSMutableOrderedSet orderedSetWithOrderedSet:self.questionIndices];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:fromIndex];
    [questionIndices moveObjectsAtIndexes:indexSet toIndex:toIndex];
    self.questionIndices = [NSOrderedSet orderedSetWithOrderedSet:questionIndices];
    
    self.editedAt = [NSDate date];
}

- (void)removeQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:question forKey:NOTIFICATION_OBJECT_KEY];
    [NSNotificationCenter postNotificationToMainThread:PQQuestionWillBeRemovedNotification object:question userInfo:nil];
    
    NSOrderedSet *primitiveQuestions = [NSOrderedSet orderedSetWithOrderedSet:self.questions];
    
    [self removeObserversFromQuestion:question];
    
    [self removeQuestionObjectsObject:question];
    [self removeQuestionIndicesObject:question.questionIndex];
    
    [self updateQuestionIndices];
    
    self.editedAt = [NSDate date];
    
    userInfo = [NSDictionary dictionaryWithObjects:@[self.questions, primitiveQuestions] forKeys:@[NOTIFICATION_OBJECT_KEY, NOTIFICATION_OLD_KEY]];
    [NSNotificationCenter postNotificationToMainThread:PQSurveyQuestionsWereRemovedNotification object:self userInfo:userInfo];
    
    NSNumber *countValue = [NSNumber numberWithInteger:self.questionObjects.count];
    userInfo = [NSDictionary dictionaryWithObject:countValue forKey:NOTIFICATION_OBJECT_KEY];
    [NSNotificationCenter postNotificationToMainThread:PQSurveyQuestionsCountDidChangeNotification object:self userInfo:userInfo];
    
    self.canBeEnabledValue = [NSNumber numberWithBool:self.canBeEnabled];
}

- (void)removeQuestionAtIndex:(NSUInteger)index {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_CORE_DATA] message:nil];
    
    PQQuestionIndex *questionIndex = [self.questionIndices objectAtIndex:index];
    
    [self removeQuestion:questionIndex.question];
}

#pragma mark - // PUBLIC METHODS (Getters) //

- (BOOL)canBeEnabled {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    if (!self.surveyId || !self.time || !self.questionObjects || !self.questionObjects.count) {
        return NO;
    }
    
    for (PQQuestion *question in self.questionObjects) {
        if (!question.questionId || !question.text || !question.text.length) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)enabled {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return self.enabledValue.boolValue;
}

- (BOOL)repeat {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    return self.repeatValue.boolValue;
}

- (NSOrderedSet <PQQuestion *> *)questions {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableOrderedSet *questions = [NSMutableOrderedSet orderedSetWithCapacity:self.questionIndices.count];
    PQQuestionIndex *questionIndex;
    PQQuestion *question;
    for (int i = 0; i < self.questionIndices.count; i++) {
        questionIndex = self.questionIndices[i];
        question = questionIndex.question;
        [questions addObject:question];
    }
    return [NSOrderedSet orderedSetWithOrderedSet:questions];
}

#pragma mark - // PUBLIC METHODS (Setters) //

- (void)setEnabled:(BOOL)enabled {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    self.enabledValue = [NSNumber numberWithBool:enabled];
}

- (void)setRepeat:(BOOL)repeat {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    self.repeatValue = [NSNumber numberWithBool:repeat];
}

- (void)setQuestions:(NSOrderedSet <PQQuestion *> *)questions {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CORE_DATA] message:nil];
    
    NSMutableOrderedSet *questionIndices = [NSMutableOrderedSet orderedSetWithCapacity:questions.count];
    PQQuestion *question;
    PQQuestionIndex *questionIndex;
    for (int i = 0; i < questions.count; i++) {
        question = questions[i];
        questionIndex = question.questionIndex;
        [questionIndices addObject:questionIndex];
    }
    self.questionObjects = questions.set;
    self.questionIndices = [NSOrderedSet orderedSetWithOrderedSet:questionIndices];
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    [super setup];
    
    for (PQQuestion *question in self.questionObjects) {
        [self addObserversToQuestion:question];
    }
}

- (void)teardown {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CORE_DATA] message:nil];
    
    for (PQQuestion *question in self.questionObjects) {
        [self removeObserversFromQuestion:question];
    }
    
    [super teardown];
}

#pragma mark - // PRIVATE METHODS (Observers) //

- (void)addObserversToQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionIdDidChange:) name:PQQuestionIdDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionTextDidChange:) name:PQQuestionTextDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionWillBeDeleted:) name:PQQuestionWillBeDeletedNotification object:question];
}

- (void)removeObserversFromQuestion:(PQQuestion *)question {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionIdDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionTextDidChangeNotification object:question];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PQQuestionWillBeDeletedNotification object:question];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)questionIdDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    self.canBeEnabledValue = [NSNumber numberWithBool:self.canBeEnabled];
}

- (void)questionTextDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    self.canBeEnabledValue = [NSNumber numberWithBool:self.canBeEnabled];
}

- (void)questionWillBeDeleted:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    PQQuestion *question = notification.object;
    
    [self removeQuestion:question];
}

#pragma mark - // PRIVATE METHODS (Other) //

- (void)updateQuestionIndices {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_DATA] message:nil];
    
    for (PQQuestionIndex *questionIndex in self.questionIndices) {
        questionIndex.indexValue = [NSNumber numberWithInteger:[self.questionIndices indexOfObject:questionIndex]];
    }
}

@end
