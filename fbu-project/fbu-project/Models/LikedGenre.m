//
//  LikedGenre.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/18/21.
//

#import "LikedGenre.h"

@implementation LikedGenre

+ (nonnull NSString *)parseClassName {
    return @"LikedGenre";
}

+ (void)postLikedGenre:(NSString *)title
               forUser:(PFUser *)user
        withCompletion:(void(^)(LikedGenre *_Nullable newLikedGenre, NSError *error))completion {
    
    LikedGenre *newLikedGenre = [LikedGenre new];
    newLikedGenre.title = title;
    newLikedGenre.user = user;
    
    [LikedGenre postLikedGenreIfNew:newLikedGenre withCompletion:completion];
}

+ (void)postLikedGenreIfNew:(LikedGenre *)likedGenre withCompletion:(void(^)(LikedGenre *_Nullable newLikedGenre, NSError *error))completion {
    PFQuery *likedGenreQuery = [PFQuery queryWithClassName:[LikedGenre parseClassName]];
    [likedGenreQuery whereKey:@"title" equalTo:likedGenre.title];
    [likedGenreQuery whereKey:@"user" equalTo:likedGenre.user];
    
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
          withCompletion:(void(^)(BOOL suceeded, NSError *_Nullable error))completion {
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
