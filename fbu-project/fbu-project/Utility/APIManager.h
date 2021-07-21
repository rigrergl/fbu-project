//
//  APIManager.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/16/21.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

+ (void)fetchGenres:(PFArrayResultBlock _Nullable)completion;

+ (NSString *)formatArtistName:(NSString *)artistName;

@end

NS_ASSUME_NONNULL_END
