//
//  LikedGenre.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/18/21.
//

#import "LikedGenre.h"
#import "DictionaryConstants.h"

@implementation LikedGenre

+ (nonnull NSString *)parseClassName {
    return LIKED_GENRE_CLASS_NAME;
}

+ (void)postLikedGenre:(NSString *)title
               forUser:(PFUser *)user
            completion:(LikedGenreReturnBlock _Nullable)completion {
    
    LikedGenre *newLikedGenre = [LikedGenre new];
    newLikedGenre.title = title;
    newLikedGenre.user = user;
    
    [LikedGenre postLikedGenreIfNew:newLikedGenre completion:completion];
}

+ (void)postLikedGenreIfNew:(LikedGenre *)likedGenre
                 completion:(LikedGenreReturnBlock _Nullable)completion {
    PFQuery *likedGenreQuery = [PFQuery queryWithClassName:[LikedGenre parseClassName]];
    [likedGenreQuery whereKey:GENRE_TITLE_KEY equalTo:likedGenre.title];
    [likedGenreQuery whereKey:LIKED_GENRE_USER_KEY equalTo:likedGenre.user];
    
    [likedGenreQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable matchingObjects, NSError *_Nullable error){
        if (!error && matchingObjects && matchingObjects.count == 0) {
            [likedGenre saveInBackgroundWithBlock:^(BOOL succeeded, NSError *_Nullable error){
                if (completion) {
                    completion(likedGenre, nil);
                }
            }];
        } else if (completion){
            completion(nil, error);
        }
    }];
}

+ (void)deleteLikedGenre:(LikedGenre *)likedGenre
              completion:(PFBooleanResultBlock _Nullable)completion {
    PFQuery *likedGenreQuery = [PFQuery queryWithClassName:[LikedGenre parseClassName]];
    [likedGenreQuery getObjectInBackgroundWithId:likedGenre.objectId block:^(PFObject *_Nullable object, NSError *_Nullable error){
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *_Nullable error){
            if (completion) {
                completion(succeeded, error);
            }
        }];
    }];
}

@end
