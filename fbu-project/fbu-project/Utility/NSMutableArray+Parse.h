//
//  NSMutableArray+Parse.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 8/3/21.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray (Parse)

- (BOOL)containsParseObjectWithId:(PFObject *_Nullable)object;

@end

NS_ASSUME_NONNULL_END
