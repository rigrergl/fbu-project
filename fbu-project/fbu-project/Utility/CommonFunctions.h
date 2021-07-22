//
//  CommonFunctions.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

//images
UIImage * resizeImage(UIImage *_Nonnull image, CGSize size);
PFFileObject * getFileFromImage(UIImage *_Nullable image);

//alerts
UIAlertController * createOkAlert(NSString *_Nullable title, NSString *_Nullable message);

NS_ASSUME_NONNULL_END
