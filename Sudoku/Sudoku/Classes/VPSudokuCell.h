//
//  SudokuCell.h
//  Sudoku
//
//  Created by Vaibhav Panchal on 19/03/2014.
//  Copyright (c) 2014 Vebz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPSudokuCell : NSObject

@property (nonatomic, assign) NSInteger across;
@property (nonatomic, assign) NSInteger down;
@property (nonatomic, assign) NSInteger region;
@property (nonatomic, assign) NSInteger value;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) UILabel *cellView;

- (void) toggleVisibleState;

- (void) setVisibleState:(BOOL)newVisibleState;

@end
