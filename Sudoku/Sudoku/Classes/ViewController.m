//
//  ViewController.m
//  Sudoku
//
//  Created by Vaibhav Panchal on 19/03/2014.
//  Copyright (c) 2014 Vebz. All rights reserved.
//

#import "ViewController.h"
#import "VPSudokuCell.h"

@interface ViewController () {
    NSMutableArray *squares;
    NSMutableArray *available;
    
    NSInteger currentSquare;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    squares = [NSMutableArray arrayWithCapacity:81];
    available = [NSMutableArray arrayWithCapacity:81];
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

    do {
        
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

@end
