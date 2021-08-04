//
//  EventsSectionHeader.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/26/21.
//

#import "EventsSectionHeader.h"

@interface EventsSectionHeader ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *separator;

@end

static CGFloat SEPARATOR_ALPHA = 0.5;

@implementation EventsSectionHeader

NSString * const EVENTS_SECTION_HEADER_REUSE_IDENTIFIER = @"EventsSectionHeader";

- (void)setTitle:(NSString *_Nonnull)title
           color:(UIColor *_Nullable)color
displaySeparator:(BOOL)displaySeparator {
    if (title) {
        self.titleLabel.text = title;
    }
    
    if (color) {
        self.titleLabel.textColor = color;
    } else {
        self.titleLabel.textColor = [UIColor blackColor];
    }
    
    if (displaySeparator) {
        self.separator.alpha = SEPARATOR_ALPHA;
    } else {
        self.separator.alpha = 0;
    }
}


@end
