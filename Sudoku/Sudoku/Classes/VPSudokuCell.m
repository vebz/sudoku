//
//  SudokuCell.m
//  Sudoku
//
//  Created by Vaibhav Panchal on 19/03/2014.
//  Copyright (c) 2014 Vebz. All rights reserved.
//

#import "VPSudokuCell.h"


@interface VPSudokuCell ()
{
    BOOL visibleState;
}
@end

@implementation VPSudokuCell


- (id) init
{
    self = [super init];
    
    if(self)
    {
        visibleState = YES;
    }
    
    return self;
}


- (void) toggleVisibleState
{
    visibleState = !visibleState;
    [self updateViewVisbility];
}


- (void) setVisibleState:(BOOL)newVisibleState
{
    visibleState = newVisibleState;
    [self updateViewVisbility];
}


- (void) updateViewVisbility
{
    CGFloat vsibility = (YES == visibleState)? 1.0f : 0.0f;
    [_cellView setAlpha:vsibility];
}

@end
