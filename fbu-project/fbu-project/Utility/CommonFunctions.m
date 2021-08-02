//
//  CommonFunctions.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import "CommonFunctions.h"
#import "DictionaryConstants.h"

static NSString * const IMAGE_NAME = @"image.png";
static NSString * const OK_ACTION_TITLE = @"OK";

#pragma mark - Images

UIImage * resizeImage(UIImage *_Nonnull image, CGSize size) {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

PFFileObject * getFileFromImage(UIImage *_Nullable image) {
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithName:IMAGE_NAME data:imageData];
}

UIImage *_Nullable DownloadUserProfileImage(PFUser *_Nonnull user) {
    if (!user) {
        return nil;
    }
    
    NSData *imageData = [user[PROFILE_IMAGE_KEY] getData];
    if (!imageData) {
        return nil;
    }
    
    return [UIImage imageWithData:imageData];
}

#pragma mark - Alerts

UIAlertController * createOkAlert(NSString *_Nullable title, NSString *_Nullable message) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:OK_ACTION_TITLE
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        // handle response here.
    }];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    
    return alert;
}

#pragma mark - Disable enable buttons

void disableButton(UIButton *_Nonnull button) {
    if (!button) {
        return;
    }
    button.alpha = 0;
    button.enabled = NO;
}

void enableButton(UIButton *_Nonnull button) {
    if (!button) {
        return;
    }
    button.alpha = 1;
    button.enabled = YES;
}
