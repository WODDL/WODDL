//
//  UIView+ScrollToTopDisabler.h
//  Woddl
//
//  Created by Oleg Komaristov on 13.01.14.
//  Copyright (c) 2014 IDS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ScrollToTopDisabler)
- (void)disableScrollToTopForSubviews;
- (void)disableDeeplyScrollToTopForSubviews;
@end
