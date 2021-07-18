//
//  APIManager+Tests.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/18/21.
//

#import "APIManager.h"

#ifndef APIManager_Tests_h
#define APIManager_Tests_h


@interface APIManager (Tests)

+ (void)generateSpotifyToken:(void(^)(NSString *_Nullable spotifyToken, NSError *_Nullable error))completion;
+ (NSString *)base64URLSafeEncode:(NSString *)originalString;

@end

#endif /* APIManager_Tests_h */
