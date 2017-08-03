//
//  UINavigationController+Fade.h
//  FitnessFaceOff
//
//  Created by Beny Boariu on 27/03/14.
//  Copyright (c) 2014 Movi Interactive, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Fade)

- (void)pushFadeViewController:(UIViewController *)viewController;

- (void)popFadeViewController;

- (void)popFadeToViewController:(id)viewController;

@end
