//
//  NSMutableArray+Parse.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 8/3/21.
//

#import "NSMutableArray+Parse.h"

@implementation NSMutableArray (Parse)

- (BOOL)containsParseObjectWithId:(PFObject *_Nullable)object {
    if (!object || !self) {
        return NO;
    }
    
    NSString *targetObjectId = object.objectId;
    BOOL __block result = NO;
    [self enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger index, BOOL *_Nonnull stop){
        if (!obj || ![obj isKindOfClass:[PFObject class]]) {
            return;
        }
        PFObject *currentObject = (PFObject *)obj;
        if ([currentObject.objectId isEqualToString:targetObjectId]) {
            result = YES;
            *stop = YES;
        }
    }];
    
    return result;
}

@end
