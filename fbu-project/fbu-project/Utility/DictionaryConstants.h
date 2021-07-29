//
//  DictionaryConstants.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/20/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DictionaryConstants : NSObject

//General
extern NSString * const OBJECT_ID_KEY;
extern NSString * const CREATED_AT_KEY;

//User
extern NSString * const RECORDING_KEY;
extern NSString * const LATITUDE_KEY;
extern NSString * const LONGITUDE_KEY;
extern NSString * const PROFILE_IMAGE_KEY;
extern NSString * const INSTRUMENTS_IN_RECORDING;
extern NSString * const BIO_KEY;

//Like
extern NSString * const LIKE_CLASS_NAME;
extern NSString * const ORIGIN_USER_KEY;
extern NSString * const DESTINATION_USER_KEY;

//UnLike
extern NSString * const UNLIKE_CLASS_NAME;

//LikedGenre
extern NSString * const LIKED_GENRE_CLASS_NAME;
extern NSString * const LIKED_GENRE_USER_KEY;
extern NSString * const GENRE_TITLE_KEY;

//Match
extern NSString * const MATCH_CLASS_NAME;
extern NSString * const MATCH_USERS_KEY;

//DirectMessage
extern NSString * const DIRECT_MESSAGE_CLASS_NAME;
extern NSString * const DIRECT_MESSAGE_MATCH_KEY;
extern NSString * const DIRECT_MESSAGE_EVENT_KEY;

//Event
extern NSString * const EVENT_DATE_KEY;
extern NSString * const EVENT_ORGANIZER_KEY;
extern NSString * const EVENT_LOCATION_KEY;
extern NSString * const EVENT_TITLE_KEY;
extern NSString * const EVENT_IMAGE_KEY;
extern NSString * const EVENT_INVITED_KEY;
extern NSString * const EVENT_ACCEPTED_KEY;

//LikedInstrument
extern NSString * const LIKED_INSTRUMENT_CLASS_NAME;
extern NSString * const LIKED_INSTRUMENT_USER_KEY;
extern NSString * const LIKED_INSTRUMENT_TITLE_KEY;

@end

NS_ASSUME_NONNULL_END
