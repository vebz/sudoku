//
//  ViewController.m
//  Sudoku
//
//  Created by Vaibhav Panchal on 19/03/2014.
//  Copyright (c) 2014 Vebz. All rights reserved.
//

#import "ViewController.h"
#import "VPSudokuCell.h"
#import "GameConfiguration.h"

enum DifficultyState
{
    DifficultyStateEasy = 0,
    DifficultyStateMedium,
    DifficultyStateHard,
};


@interface ViewController () {
    NSMutableArray *squares;
    NSMutableArray *available;
    
    NSInteger currentSquare;
    
    // Difficulty Settings
    enum DifficultyState difficultyState;
    NSRange *difficultyRange;
    NSInteger numberOfVisibleCells;
    NSInteger lowerBoundOfCell;
    CGFloat correlationValue; // Scatter of points determine how distributed our cells across the grid is.
    NSInteger difficultyScore;
}

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    squares = [NSMutableArray arrayWithCapacity:81];
    available = [NSMutableArray arrayWithCapacity:81];
    
    [_difficultySlider setValue:DifficultyStateEasy];
    
    [self setDifficultySettings];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Grid Generation

- (void)initializeGrid
{
    for(VPSudokuCell *currentCell in squares)
    {
        if(nil != currentCell)
        {
            [currentCell setVisibleState:NO];
        }
    }
    
    @autoreleasepool {
        
        // Get the selected positions.
        NSMutableArray *totalColoums = [NSMutableArray arrayWithCapacity:9];
        for(int i = 0 ; i < 9; i++)
        {
            NSNumber *colNum = [NSNumber numberWithInteger:(i+1)];
            [totalColoums addObject:colNum];
        }
        
        // We inverse a no correlation value (0 means complete spread).
        // Then divide it by total number of regions available.
        // That gives how many regions shall the cells be spread across.
        // So for easy level, the spread should be across all the regions.
        // Hence, we divide by total regions.
        const CGFloat SPREAD_PER_REGION = 1.0f / 3.0f;
        NSInteger regionsSelected =  (1 - correlationValue) / SPREAD_PER_REGION; // Get total of number of regions we should select.
        if(0 == regionsSelected)
            regionsSelected++; // Need atleast one region per slice
        
        NSInteger regionSelectedInverse = totalRegionPerHorizontalSlice - regionsSelected; // Use elimination method to remove region from complete region list.
        NSMutableArray *selectedRegions = [NSMutableArray arrayWithCapacity:3];
        NSMutableArray *selectedRegionIndices = [NSMutableArray arrayWithCapacity:(regionsSelected * totalRegionPerVerticalSlice)];
        
        // Fill total number regions per slice
        for (int i = 0; i < totalRegionPerVerticalSlice; i++)
        {
            selectedRegions[i] = [NSMutableArray arrayWithCapacity:totalRegionPerHorizontalSlice];
            
            for (int j = 0; j < totalRegionPerHorizontalSlice; j++)
            {
                selectedRegions[i][j] = [NSNumber numberWithInteger: ((totalRegionPerVerticalSlice * j) + i)];
            }
        }
        
        // Remove the regions out of total regions per slice based on difficulty.
        for (int i = 0; i < totalRegionPerVerticalSlice; i++)
        {
            NSMutableArray *selectedRegion = selectedRegions[i];
            for (int j = 0; j < regionSelectedInverse; j++) {
                NSInteger eliminateRegionIndex = arc4random_uniform(selectedRegion.count);
                [selectedRegion removeObjectAtIndex:eliminateRegionIndex];
            }
            
            [selectedRegionIndices addObjectsFromArray:selectedRegion];
        }
        
        NSMutableArray *squaresClone = [NSMutableArray arrayWithArray:[squares copy]];
        NSMutableArray *selectedVisibleCells = [NSMutableArray arrayWithCapacity:numberOfVisibleCells];
        NSInteger totalVisibleCells = numberOfVisibleCells;
        
        do
        {
            int cellIndex = arc4random_uniform(squaresClone.count);
            VPSudokuCell *cell = squaresClone[cellIndex];
            
            [cell toggleVisibleState];
            [selectedVisibleCells addObject:cell];
            totalVisibleCells--;
            
            [squaresClone removeObjectAtIndex:cellIndex];
        } while (totalVisibleCells > 0 &&
                 squaresClone.count > 0);
    }    
}


- (void)generateGrid
{
    currentSquare = 0;
    
    for(int i = 0; i < 81; i++)
    {
        available[i] = [NSMutableArray arrayWithCapacity:9];
        
        for(int j = 0; j < 9; j++)
        {
            available[i][j] = [NSNumber numberWithInt:(j+1)];
        }
    }

    do
    {
        NSMutableArray *currentAvailable = (NSMutableArray *)available[currentSquare];
        if(!currentAvailable.count == 0)
        {
            NSInteger randPosInCurrAvailable = arc4random_uniform(currentAvailable.count);
            NSNumber *valueNumber = currentAvailable[randPosInCurrAvailable];
            NSInteger value = valueNumber.intValue;
            
            VPSudokuCell *item = [self createCellWithCurrentSquare : currentSquare AndValue:value];
            
            if(![self validateConflict:item])
            {
                [squares insertObject:item atIndex:currentSquare];
                [currentAvailable removeObjectAtIndex:randPosInCurrAvailable];
                currentSquare++;
            }
            else
            {
                [currentAvailable removeObjectAtIndex:randPosInCurrAvailable];
            }
            
        }
        else
        {
            for(int j=0; j<9; j++)
            {
                currentAvailable[j] = [NSNumber numberWithInt:(j+1)];
            }
            
            [squares removeObjectAtIndex:(currentSquare-1)];
            currentSquare--;
        }
    } while(currentSquare < 81);
    
    NSLog(@"Grid generated");
    
    // Debug output.
    for(int i = 0; i < 81; i++)
    {
        VPSudokuCell *cell = squares[i];
        UILabel *label = [[UILabel alloc] init];
        const NSInteger width = 40.0f;
        [label setFrame:CGRectMake(cell.down * width, cell.across * width, width, width)];
        NSString *labelText = [NSString stringWithFormat:@"%d", cell.value];
        [label setText:labelText];
        
        cell.cellView = label;
        [self.view addSubview:label];
    }
}


#pragma mark - Cell Initialization

- (VPSudokuCell *) createCellWithCurrentSquare : (NSInteger )currentSquareNumber
                                      AndValue : (NSInteger)randomValue
{
    VPSudokuCell *tempCell = [[VPSudokuCell alloc] init];
    
    NSInteger sqNum = currentSquareNumber + 1;
    
    tempCell.down = [self getDownValue:sqNum];
    tempCell.region = [self getRegionValue:sqNum];
    tempCell.across = [self getAcrossValue : sqNum];
    tempCell.index = currentSquareNumber;
    tempCell.value = randomValue;
    
    return tempCell;
}


- (NSInteger) getAcrossValue : (NSInteger ) sqNum
{
    NSInteger acrossValue;
    
    acrossValue = sqNum % 9;
    
    if(0 == acrossValue)
        acrossValue = 9;
    
    return acrossValue;
}


- (NSInteger) getDownValue : (NSInteger ) sqNum
{
    NSInteger value = [self getAcrossValue:sqNum];
    value = (value == 9)? (sqNum / 9) : ((sqNum / 9) + 1);
    
    return value;
}


- (NSInteger) getRegionValue : (NSInteger ) sqNum
{
    NSInteger value = -1;
    NSInteger acrossValue = [self getAcrossValue:sqNum];
    NSInteger downValue = [self getDownValue:sqNum];
    
    if(1 <= acrossValue && acrossValue < 4 && 1 <= downValue && downValue < 4)
    {
        value = 1;
    }
    else if(4 <= acrossValue && acrossValue < 7 && 1 <= downValue && downValue < 4)
    {
        value = 2;
    }
    else if(7 <= acrossValue && acrossValue < 10 && 1 <= downValue && downValue < 4)
    {
        value = 3;
    }
    else if(1 <= acrossValue && acrossValue < 4 && 4 <= downValue && downValue < 7)
    {
        value = 4;
    }
    else if(4 <= acrossValue && acrossValue < 7 && 4 <= downValue && downValue < 7)
    {
        value = 5;
    }
    else if(7 <= acrossValue && acrossValue < 10 && 4 <= downValue && downValue < 7)
    {
        value = 6;
    }
    else if(1 <= acrossValue && acrossValue < 4 && 7 <= downValue && downValue < 10)
    {
        value = 7;
    }
    else if(4 <= acrossValue && acrossValue < 7 && 7 <= downValue && downValue < 10)
    {
        value = 8;
    }
    else if(7 <= acrossValue && acrossValue < 10 && 7 <= downValue && downValue < 10)
    {
        value = 9;
    }
    
    return value;
}

#pragma mark - Validation

-(BOOL) validateConflict : (VPSudokuCell *) newItem
{
    BOOL conflict = NO;
    for(int i = 0; i < squares.count; i++)
    {
        VPSudokuCell *existingCell = squares[i];
        
        if((existingCell.across == newItem.across && existingCell.across != 0) ||
           (existingCell.down == newItem.down && existingCell.down != 0) ||
           (existingCell.region == newItem.region && existingCell.region != 0))
        {
            if(existingCell.value == newItem.value)
            {
                conflict = YES;
            }
        }
    }
    
    return conflict;
}


- (void)validateRulesAndSettings
{
    NSAssert(DifficultyStateEasy == difficultyState ||
             DifficultyStateMedium == difficultyState ||
             DifficultyStateHard == difficultyState,
             @"Incorrect Difficulty State");
    
    NSAssert(DIFFICULTY_EASY ==  _difficultySlider.value ||
             DIFFICULTY_MEDIUM == _difficultySlider.value ||
             DIFFICULTY_HARD == _difficultySlider.value,
             @"Incorrect Difficulty Value in slider");
}


#pragma mark - User Actions Bindings

- (IBAction)generateSudokuGrid:(id)sender
{
    NSLog(@"Generating New Sudoku Grid");
    for (int i = 0; i < squares.count; i++)
    {
        VPSudokuCell *cell = squares[i];
        [cell.cellView removeFromSuperview];
        cell.cellView = nil;
    }
    
    [squares removeAllObjects];
    [available removeAllObjects];

    [self generateGrid];
}


- (IBAction)createSudokuFromGrid:(id)sender
{
    [self validateRulesAndSettings];
    [self initializeGrid];
}


- (IBAction)difficultyValueChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    
    if(slider.value <= 0.35f)
    {
        slider.value = DIFFICULTY_EASY;
    }
    else if(slider.value > 0.35f && slider.value < 0.75f)
    {
        slider.value = DIFFICULTY_MEDIUM;
    }
    else if(slider.value >= 0.75f)
    {
        slider.value = DIFFICULTY_HARD;
    }
    
    
    NSAssert(DIFFICULTY_EASY == slider.value ||
             DIFFICULTY_MEDIUM == slider.value ||
             DIFFICULTY_HARD == slider.value, @"Incorrect Difficulty Settings");
    
    
    if(nil != slider &&
       [slider isKindOfClass:[UISlider class]])
    {
        
        if(DIFFICULTY_EASY == slider.value)
        {
            difficultyState = DifficultyStateEasy;
        }
        else if (DIFFICULTY_MEDIUM == slider.value)
        {
            difficultyState = DifficultyStateMedium;
            
        }
        else if(DIFFICULTY_HARD == slider.value)
        {
            difficultyState = DifficultyStateHard;
        }
    }
    
    [self setDifficultySettings];
}


#pragma mark - Difficulty Management

- (void)setDifficultySettings
{
    @autoreleasepool {
        const NSInteger LOWER_BOUND_EASY = 50;
        const NSInteger HIGHER_BOUND_EASY = 60;
        const CGFloat LOWER_BOUND_CORRELATION_EASY = 0.0f;
        const CGFloat HIGHER_BOUND_CORRELATION_EASY = 0.33f;
        
        const NSInteger LOWER_BOUND_MEDIUM = 36;
        const NSInteger HIGHER_BOUND_MEDIUM = 45;
        const CGFloat LOWER_BOUND_CORRELATION_MEDIUM = 0.34f;
        const CGFloat HIGHER_BOUND_CORRELATION_MEDIUM = 0.66f;
        
        const NSInteger LOWER_BOUND_HARD = 22;
        const NSInteger HIGHER_BOUND_HARD = 27;
        const CGFloat LOWER_BOUND_CORRELATION_HARD = 0.67f;
        const CGFloat HIGHER_BOUND_CORRELATION_HARD = 1.0f;
        
        srand48(time(0));
        double randomValue = drand48();
        
        switch (difficultyState)
        {
            case DifficultyStateEasy:
            {
                numberOfVisibleCells = LOWER_BOUND_EASY + ((HIGHER_BOUND_EASY - LOWER_BOUND_EASY) * randomValue);
                correlationValue = LOWER_BOUND_CORRELATION_EASY + ((HIGHER_BOUND_CORRELATION_EASY - LOWER_BOUND_CORRELATION_EASY) * randomValue);
            }break;
                
            case DifficultyStateMedium:
            {
                numberOfVisibleCells = LOWER_BOUND_MEDIUM + ((HIGHER_BOUND_MEDIUM - LOWER_BOUND_MEDIUM) * randomValue);
                correlationValue = LOWER_BOUND_CORRELATION_MEDIUM + ((HIGHER_BOUND_CORRELATION_MEDIUM - LOWER_BOUND_CORRELATION_MEDIUM) * randomValue);
            }break;
                
            case DifficultyStateHard:
            {
                numberOfVisibleCells = LOWER_BOUND_HARD +  ((HIGHER_BOUND_HARD - LOWER_BOUND_HARD) * randomValue);
                correlationValue = LOWER_BOUND_CORRELATION_HARD + ((HIGHER_BOUND_CORRELATION_HARD - LOWER_BOUND_CORRELATION_HARD) * randomValue);
            }break;
                
            default:
            {
                NSAssert(YES, @"Incorrect difficulty settings");
            }break;
        }
        
        double ratio = numberOfVisibleCells / 81.0f;
        if(ratio < 0.5f)
        {
            double floor = ceilf(numberOfVisibleCells / NUMBER_OF_CELLS_PER_ROW_AND_COLS);
            lowerBoundOfCell = floor;
        }
        else
        {
            double ceiling = floorf(numberOfVisibleCells / NUMBER_OF_CELLS_PER_ROW_AND_COLS);
            lowerBoundOfCell = ceiling;
        }
    }
//    NSLog(@"Number of visible cells %d", numberOfVisibleCells);
//    NSLog(@"Random Value %f", randomValue);
//    NSLog(@"Correlation Value %f", correlationValue);
//    NSLog(@"Lower Bound Cells %d", lowerBoundOfCell);
}

@end
