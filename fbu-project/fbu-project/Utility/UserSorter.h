//
//  UserSorter.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/19/21.
//

#import <Foundation/Foundation.h>
#import "LikedGenre.h"
#import "LikedInstrument.h"

NS_ASSUME_NONNULL_BEGIN

extern NSArray *_Nullable Recommended(void);

extern NSArray<PFUser *> *_Nullable NotLikedUsers(void);
extern CLLocation * LocationForUser(PFUser *_Nonnull user);
extern CGFloat DistanceBetweenUsers(PFUser *_Nonnull user1, PFUser *_Nonnull user2);
extern NSInteger PointsForDistance(double distance);
extern NSSet<NSString *> * SetWithGenreTitles(NSArray<LikedGenre *> *_Nonnull likedGenres);
extern NSInteger PointsForCommonGenres(PFUser *_Nonnull user1, PFUser *_Nonnull user2);
NSInteger PointsForMatchingInstrumentsInRecording(PFUser *_Nonnull otherUser);
extern NSNumber * RankUserForUser(PFUser *_Nonnull recommendedUser, PFUser *_Nonnull currentUser);

NS_ASSUME_NONNULL_END
