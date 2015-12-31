//
//  SearchOperationViewController.m
//  SFToLF
//
//  Created by Harshal Joshi on 12/28/15.
//  Copyright © 2015 Indi-Joshi. All rights reserved.
//


#import "SearchOperationViewController.h"
static NSString * const BaseURLString = @"http://www.nactem.ac.uk/software/acromine/dictionary.py";

@interface SearchOperationViewController ()
@property(strong) NSDictionary *jsonDictionary;
@property(strong) NSArray *jsonData;
@property(strong) AFHTTPRequestOperation *operation;
@end

@implementation SearchOperationViewController
@synthesize jsonData;
@synthesize jsonDictionary;
@synthesize operation;
@synthesize searchQueryResultTable;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (jsonData) {
        self.searchQueryResultTable.backgroundView = nil;

        return 1;
    }
    else
    {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No Results.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [messageLabel sizeToFit];
        
        self.searchQueryResultTable.backgroundView = messageLabel;
        self.searchQueryResultTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!jsonData) {
        return 0;
    }
    return jsonData.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [[jsonData objectAtIndex:indexPath.row] objectForKey:@"lf"];
    return cell;
}
#pragma mark - UITableViewDelegate

-(IBAction)updateSearchQuery:(id)sender
{
    if ([(UITextField *)sender text].length>0)
    {
        [self searchAbrivationDefinition:[(UITextField *)sender text]];
    }
    else
    {
        jsonData=nil;
        [self.searchQueryResultTable reloadData];
    }
}
#pragma mark - Networking
-(void)searchAbrivationDefinition:(NSString *)searchQuery;
{
    NSString *string = [NSString stringWithFormat:@"%@?sf=%@", BaseURLString,searchQuery];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Loading";
    __weak typeof(self) weakSelf = self;
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             [hud show:YES];
            NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if (dataArray.count>0) {
                jsonData= [[dataArray objectAtIndex:0] objectForKey:@"lfs"];
            }
            else
                jsonData = nil;
            [weakSelf.searchQueryResultTable reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alertController dismissViewControllerAnimated:YES completion:nil];
                                 }];
            [alertController addAction:ok];
            [weakSelf presentViewController:alertController animated:YES completion:nil];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
        });
    [operation start];
}
@end
