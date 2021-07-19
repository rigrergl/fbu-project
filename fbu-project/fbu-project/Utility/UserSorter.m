//
//  UserSorter.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/19/21.
//

#import <Parse/Parse.h>
#import "UserSorter.h"
#import "Like.h"
#import "DictionaryConstants.h"


static const int POINTS_FOR_VERY_SHORT_DISTANCE = 0; //0-10 miles
static const int POINTS_FOR_SHORT_DISTANCE = 5; //10-50 miles
static const int POINTS_FOR_MEDIUM_DISTANCE = 10; //50-100 miles
static const int POINTS_FOR_LONG_DISTANCE = 20; //100-500 miles
static const int POINTS_FOR_VERY_LONG_DISTANCE = 40; //500-1000 miles
static const int POINTS_FOR_MAX_DISTANCE = 60; //1000+ miles

static const int POINTS_FOR_COMMON_GENRE = -5;

NSArray<PFUser *> *_Nullable NotLikedUsers(void) {
    if ([PFUser currentUser] == nil) {
        return nil;
    }
    
    PFQuery *likeQuery = [PFQuery queryWithClassName:[Like parseClassName]];
    [likeQuery whereKey:ORIGIN_USER_KEY  equalTo:[PFUser currentUser]];
    
    NSArray<Like *> *likes = [likeQuery findObjects];
    if (likes) {
        PFQuery *notLikedUsersQuery = [PFQuery queryWithClassName: [PFUser parseClassName]];
        [notLikedUsersQuery whereKey:OBJECT_ID_KEY notEqualTo:[PFUser currentUser].objectId];
        
        NSMutableArray<NSString *> *likedUserIds = [[NSMutableArray alloc] init];
        for (Like *like in likes) {
            PFUser *destinationUser = like[DESTINATION_USER_KEY];
            [likedUserIds addObject:destinationUser.objectId];
        }
        
        [notLikedUsersQuery whereKey:OBJECT_ID_KEY notContainedIn:likedUserIds];
        [notLikedUsersQuery includeKey:RECORDING_KEY];
        
        NSArray<PFUser *> *notLikedUsers = [notLikedUsersQuery findObjects];
        if (notLikedUsers) {
            return notLikedUsers;
        }
    }
    
    return nil;
}

CLLocation * LocationForUser(PFUser *_Nonnull user) {
    if (user && user[LATITUDE_KEY] && user[LONGITUDE_KEY]) {
        CLLocationDegrees latitude = [user[LATITUDE_KEY] doubleValue];
        CLLocationDegrees longitude = [user[LONGITUDE_KEY] doubleValue];
        
        return [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    } else {
        return nil;
    }
}

double DistanceBetweenUsers(PFUser *_Nonnull user1, PFUser *_Nonnull user2) {
    CLLocation *currentUserLocation = LocationForUser(user1);
    CLLocation *otherUserLocation = LocationForUser(user2);
    
    if (currentUserLocation == nil || otherUserLocation == nil) {
        return CGFLOAT_MAX;
    } else {
        return [currentUserLocation distanceFromLocation:otherUserLocation];
    }
}

int PointsForDistance(double distance) {
    if (distance < 0) {
        return 0;
    }
    
    if (distance < 10) {
        return POINTS_FOR_VERY_SHORT_DISTANCE;
    } else if (distance < 50) {
        return POINTS_FOR_SHORT_DISTANCE;
    } else if (distance < 100) {
        return POINTS_FOR_MEDIUM_DISTANCE;
    } else if (distance < 500) {
        return POINTS_FOR_LONG_DISTANCE;
    } else if (distance < 1000) {
        return POINTS_FOR_VERY_LONG_DISTANCE;
    } else {
        return POINTS_FOR_MAX_DISTANCE;
    }
}

NSSet<NSString *> * SetWithGenreTitles(NSArray<LikedGenre *> *_Nonnull likedGenres) {
    if (likedGenres == nil) {
        return nil;
    }
    
    NSMutableSet<NSString *> *genreTitles = [NSMutableSet setWithCapacity:likedGenres.count];
    for (LikedGenre *likedGenre in likedGenres) {
        [genreTitles addObject:likedGenre.title];
    }
    
    return genreTitles;
}

int PointsForCommonGenres(PFUser *_Nonnull user1, PFUser *_Nonnull user2) {
    if (user1 == nil || user2 == nil) {
        return 0;
    }
    
    PFQuery *likedGenresQuery = [PFQuery queryWithClassName:[LikedGenre parseClassName]];
    [likedGenresQuery includeKey:GENRE_TITLE_KEY];
    
    [likedGenresQuery whereKey:LIKED_GENRE_USER_KEY equalTo:user1];
    NSError *error;
    NSArray<LikedGenre *> *user1LikedGenres = [likedGenresQuery findObjects:&error];
    if (error || !user1LikedGenres) {
        return 0;
    }
    
    [likedGenresQuery whereKey:LIKED_GENRE_USER_KEY equalTo:user2];
    NSArray<LikedGenre *> *user2LikedGenres = [likedGenresQuery findObjects:&error];
    if (error || !user2LikedGenres) {
        return 0;
    }
    
    int genrePoints = 0;
    NSSet<NSString *> *user1GenresTitlesSet = SetWithGenreTitles(user1LikedGenres);
    for (LikedGenre *likedGenre in user2LikedGenres) {
        if ([user1GenresTitlesSet containsObject:likedGenre.title]) {
            genrePoints += POINTS_FOR_COMMON_GENRE;
        }
    }
    
    return genrePoints;
}

NSNumber * RankUserForUser(PFUser *_Nonnull recommendedUser, PFUser *_Nonnull currentUser) {
    if (recommendedUser == nil || currentUser == nil) {
        return @INT_MAX;
    }
    
    //higher numbers = lower priority
    int rank = 0;
    
    double distance = DistanceBetweenUsers(currentUser, recommendedUser);
    rank += PointsForDistance(distance);
    
    rank += PointsForCommonGenres(recommendedUser, currentUser);
    
    return [NSNumber numberWithInt:rank];
}

NSArray<PFUser *> *_Nullable Recommended(void) {
    NSArray<PFUser *> *notLikedUsers = NotLikedUsers();
    if (notLikedUsers) {
        //assign ranks to each remaining user
        NSMutableDictionary<NSString *, NSNumber *> *userRankings = [[NSMutableDictionary alloc] initWithCapacity:notLikedUsers.count];
        for (PFUser *user in notLikedUsers) {
            NSNumber *rank = RankUserForUser(user, [PFUser currentUser]);
            [userRankings setValue:rank forKey:user.objectId];
        }
        
        //sort using rank
        notLikedUsers = [notLikedUsers sortedArrayUsingComparator:^NSComparisonResult(PFUser *_Nonnull user1, PFUser *_Nonnull user2) {
            NSNumber *user1Rank = [userRankings valueForKey:user1.objectId];
            NSNumber *user2Rank = [userRankings valueForKey:user2.objectId];
            return [user1Rank compare:user2Rank];
        }];
        
        return notLikedUsers;
    } else {
        return nil;
    }
}
