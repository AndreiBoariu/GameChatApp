//
//  UINavigationController+Fade.m
//  FitnessFaceOff
//
//  Created by Beny Boariu on 27/03/14.
//  Copyright (c) 2014 Movi Interactive, Inc. All rights reserved.
//

#import "UINavigationController+Fade.h"

@implementation UINavigationController (Fade)

- (void)pushFadeViewController:(UIViewController *)viewController
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
	[self.view.layer addAnimation:transition forKey:nil];
	
	[self pushViewController:viewController animated:NO];
}

- (void)popFadeViewController
{
	CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
	[self.view.layer addAnimation:transition forKey:nil];
	[self popViewControllerAnimated:NO];
}

- (void)popFadeToViewController:(id)viewController
{
	CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
	[self.view.layer addAnimation:transition forKey:nil];
	[self popToViewController:viewController animated:NO];
}

@end
