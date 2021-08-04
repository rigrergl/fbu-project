//
//  EventsSectionHeader.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/26/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EventsSectionHeader : UICollectionReusableView

extern NSString * const EVENTS_SECTION_HEADER_REUSE_IDENTIFIER;

- (void)setTitle:(NSString *_Nonnull)title
           color:(UIColor *_Nullable)color
displaySeparator:(BOOL)displaySeparator;

@end

NS_ASSUME_NONNULL_END
