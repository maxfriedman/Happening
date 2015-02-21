//
//  NewEventFrequencyTVC.m
//  Happening
//
//  Created by Max on 1/3/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "NewEventFrequencyTVC.h"

@interface NewEventFrequencyTVC ()

@property (strong, nonatomic) IBOutlet UILabel *repeatLabel;

@property (strong, nonatomic) IBOutlet UILabel *frequencyLabel;

@property (strong, nonatomic) IBOutlet UIPickerView *frequencyPicker;

@end

@implementation NewEventFrequencyTVC {
    
    NSArray *pickerData;
    NSArray *labelData;
    NSArray *footerData;
    NSInteger currentRow;
    
}

@synthesize repeats, repeatLabel, frequencyLabel, frequencyPicker;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    
    currentRow = 1;
    //self.frequencyInt = 3; data is now set when segue is performed
    //So we set 3 as default if it's first time opening page
    if (self.frequencyInt == 1) {
        self.frequencyInt = 3;
    }
    
    [self.delegate passFrequencyData:self.frequencyInt];
    
    if (repeats == 1) { // weekly
        
        repeatLabel.text = @"Weekly";
        frequencyLabel.text = @"Three weeks";
        pickerData  = [[NSArray alloc]initWithObjects: @"2", @"3", @"4", @"5", nil];
        labelData = [[NSArray alloc]initWithObjects: @"Two weeks", @"Three weeks", @"Four weeks", @"Five weeks", nil];
        footerData = [[NSArray alloc]initWithObjects:@"week for two weeks for a total of TWO events", @"week for three weeks for a total of THREE events", @"week for four weeks for a total of FOUR events", @"week for five weeks for a total of FIVE events", nil];
        
    } else if (repeats == 2) { // biweekly
        
        repeatLabel.text = @"Biweekly";
        frequencyLabel.text = @"Four weeks";
        pickerData  = [[NSArray alloc]initWithObjects:@"2", @"4", @"6", @"8", @"10", nil];
        labelData = [[NSArray alloc]initWithObjects:@"Two weeks", @"Four weeks", @"Six weeks", @"Eight weeks", @"Ten weeks", nil];
        footerData = [[NSArray alloc]initWithObjects:@"other week for two weeks for a total of TWO events", @"other week for four weeks for a total of THREE events", @"other week for six weeks for a total of FOUR events", @"other week for eight weeks for a total of FIVE events", @"other week for ten weeks for a total of SIX events", nil];
        
    } else { // monthly
        
        repeatLabel.text = @"Monthly";
        frequencyLabel.text = @"Three months";
        pickerData  = [[NSArray alloc]initWithObjects: @"2", @"3", @"4", @"5", nil];
        labelData = [[NSArray alloc]initWithObjects: @"Two months", @"Three months", @"Four months", @"Five months", nil];
        footerData = [[NSArray alloc]initWithObjects:@"month for two months for a total of TWO events", @"month for three months for a total of THREE events", @"month for four months for a total of FOUR events", @"month for five months for a total of FIVE events", nil];
        
    }
    
    //frequencyLabel.text = labelData[2];
    [frequencyPicker selectRow: (self.frequencyInt - 2)  inComponent:0 animated:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (component == 0) {
        return pickerData.count;
    } else {
        return 1;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (component == 0) {
        
        return pickerData[row];

    } else {
        
        if (repeats == 1) { // weekly

            return @"weeks";
            
            /*
            if ([pickerView selectedRowInComponent:0] == 0) {
            
                return @"week";
                
            } else {
                
                return @"weeks";
            }
             */
            
        } else if (repeats == 2) { // biweekly

            return @"weeks";
            
        } else { // monthly
            
            /*
            if ([pickerView selectedRowInComponent:0] == 0) {
                
                return @"month";
            } else {
                
                return @"months";
            }
             */
            return @"months";
            
        }
    }
    
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (component == 0) {
        frequencyLabel.text = labelData[row];
        currentRow = row;
        self.frequencyInt = (int)row + 2;
        [self.delegate passFrequencyData:self.frequencyInt];
        [self.tableView reloadData];
    }
    
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if (section == 2) {
        
        NSString *footerString = [NSString stringWithFormat:@"Event will occur every %@", footerData[currentRow]];
        return footerString;
        
    }
    
    return nil;
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
