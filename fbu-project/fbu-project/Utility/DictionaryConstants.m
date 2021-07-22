//
//  DictionaryConstants.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/20/21.
//

#import "DictionaryConstants.h"

@implementation DictionaryConstants

//General
NSString * const OBJECT_ID_KEY = @"objectId";
NSString * const CREATED_AT_KEY = @"createdAt";

//User
NSString * const RECORDING_KEY = @"recording";
NSString * const LATITUDE_KEY = @"latestLatitude";
NSString * const LONGITUDE_KEY = @"latestLongitude";
NSString * const PROFILE_IMAGE_KEY = @"profileImage";

//Like
NSString * const LIKE_CLASS_NAME = @"Like";
NSString * const ORIGIN_USER_KEY = @"originUser";
NSString * const DESTINATION_USER_KEY = @"destinationUser";

//UnLike
NSString * const UNLIKE_CLASS_NAME = @"UnLike";

//LikedGenre
NSString * const LIKED_GENRE_CLASS_NAME = @"LikedGenre";
NSString * const LIKED_GENRE_USER_KEY = @"user";
NSString * const GENRE_TITLE_KEY = @"title";

//Match
NSString * const MATCH_CLASS_NAME = @"Match";
NSString * const MATCH_USERS_KEY = @"users";

//DirectMessage
NSString * const DIRECT_MESSAGE_CLASS_NAME = @"DirectMessage";
NSString * const DIRECT_MESSAGE_MATCH_KEY = @"match";
NSString * const DIRECT_MESSAGE_EVENT_KEY = @"event";

//Event
NSString * const EVENT_DATE_KEY = @"date";
NSString * const EVENT_ORGANIZER_KEY = @"organizer";
NSString * const EVENT_LOCATION_KEY = @"location";
NSString * const EVENT_TITLE_KEY = @"title";
NSString * const EVENT_IMAGE_KEY = @"image";
NSString * const EVENT_INVITED_KEY = @"invited";
NSString * const EVENT_ACCEPTED_KEY = @"accepted";

@end
