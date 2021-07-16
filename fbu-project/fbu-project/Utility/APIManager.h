//
//  APIManager.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/16/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

- (void)fetchArtist:(NSString *)artistId
     withCompletion:(void(^)(NSDictionary *_Nullable responseDictionary,NSError *_Nullable error))completion;

+ (NSString *)formatArtistName:(NSString *)artistName;

@end

NS_ASSUME_NONNULL_END
