//
//  GameConfiguration.h
//  Sudoku
//
//  Created by Vaibhav Panchal on 23/03/2014.
//  Copyright (c) 2014 Vebz. All rights reserved.
//

#ifndef Sudoku_GameConfiguration_h
#define Sudoku_GameConfiguration_h

const CGFloat DIFFICULTY_EASY = 0.0f;
const CGFloat DIFFICULTY_MEDIUM = 0.50f;
const CGFloat DIFFICULTY_HARD = 1.0f;

const NSInteger NUMBER_OF_CELLS_PER_ROW_AND_COLS = 9; // Number of cells in a rows and cols. Used for correlation value.

const NSInteger TOTAL_ROWS = 9;
const NSInteger TOTAL_COLUMNS = 9;
const NSInteger GRID_DIMENSION = TOTAL_ROWS * TOTAL_COLUMNS;

const NSInteger TOTAL_SUDOKU_NUMBERS = 9; // Number of cells in a rows and cols. Used for correlation value.
const NSInteger REGIONS = 6;

const NSInteger totalRegionPerVerticalSlice = 3;
const NSInteger totalRegionPerHorizontalSlice = 3;

#endif
