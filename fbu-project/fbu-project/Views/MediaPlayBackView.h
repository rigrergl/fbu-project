//
//  MediaPlayBackView.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/15/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MediaPlayBackView : UIView

- (id)initWithFrame:(CGRect)frame
            andData:(NSData *_Nonnull)data;

- (void)stopPlaying;

@end

NS_ASSUME_NONNULL_END
