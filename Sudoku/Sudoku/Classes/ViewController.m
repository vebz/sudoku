//
//  ViewController.m
//  Sudoku
//
//  Created by Vaibhav Panchal on 19/03/2014.
//  Copyright (c) 2014 Vebz. All rights reserved.
//

#import "ViewController.h"
#import "VPSudokuCell.h"


enum DifficultyState {
    DifficultyStateEasy = 0,
    DifficultyStateMedium,
    DifficultyStateHard,
};

@interface ViewController () {
    NSMutableArray *squares;
    NSMutableArray *available;
    
    NSInteger currentSquare;
    
    enum DifficultyState difficultyState;
    NSRange *difficultyRange;
    NSInteger numberOfVisibleCells;
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
    [self generateGrid];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) generateGrid
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
    } while (currentSquare < 81);
    
    NSLog(@"Grid generated");
    // Debug output.
    for(int i = 0; i < 81; i++)
    {
        VPSudokuCell *cell = squares[i];
        UILabel *label = [[UILabel alloc] init];
        const NSInteger width = 20.0f;
        [label setFrame:CGRectMake(cell.down * width, cell.across * width, width, width)];
        NSString *labelText = [NSString stringWithFormat:@"%d", cell.value];
        [label setText:labelText];
        [self.view addSubview:label];
    }
}


- (VPSudokuCell *) createCellWithCurrentSquare : (NSInteger )currentSquareNumber AndValue : (NSInteger)randomValue
{
    VPSudokuCell *tempCell = [[VPSudokuCell alloc] init];
    
    NSInteger sqNum = currentSquareNumber + 1;
    
    tempCell.across = [self getAcrossValue : sqNum];
    tempCell.down = [self getDownValue:sqNum];
    tempCell.region = [self getRegionValue:sqNum];
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
    NSInteger value;
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


- (IBAction)generateSudokuGrid:(id)sender
{
    NSLog(@"Generating New Sudoku Grid");
}

- (IBAction)createSudokuFromGrid:(id)sender
{
//    for(int i = 0; i < )
}

- (IBAction)solveSudoku:(id)sender
{
    
}

- (IBAction)difficultyValueChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    
    const CGFloat DIFFICULTY_EASY = 0.00f;
    const CGFloat DIFFICULTY_MEDIUM = 0.50f;
    const CGFloat DIFFICULTY_HARD = 1.0f;
    
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


- (void)setDifficultySettings
{
    const NSInteger LOWER_BOUND_EASY = 50;
    const NSInteger HIGHER_BOUND_EASY = 60;
    
    const NSInteger LOWER_BOUND_MEDIUM = 36;
    const NSInteger HIGHER_BOUND_MEDIUM = 49;
    
    const NSInteger LOWER_BOUND_HARD = 22;
    const NSInteger HIGHER_BOUND_HARD = 27;
    
    srand48(time(0));
    double randomValue = drand48();

    switch (difficultyState)
    {
        case DifficultyStateEasy:
        {
           numberOfVisibleCells = LOWER_BOUND_EASY + ((HIGHER_BOUND_EASY - LOWER_BOUND_EASY) * randomValue);
        }break;
            
        case DifficultyStateMedium:
        {
            numberOfVisibleCells = LOWER_BOUND_MEDIUM + ((HIGHER_BOUND_MEDIUM - LOWER_BOUND_MEDIUM) * randomValue);
            
        }break;
            
        case DifficultyStateHard:
        {
            numberOfVisibleCells = LOWER_BOUND_HARD +  ((HIGHER_BOUND_HARD - LOWER_BOUND_HARD) * randomValue);
        }break;
            
        default:
        {
            NSAssert(YES, @"Incorrect difficulty settings");
        }break;
    }
    
    NSLog(@"Number of visible cells %d", numberOfVisibleCells);
}


@end
