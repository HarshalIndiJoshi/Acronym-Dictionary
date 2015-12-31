//
//  SearchOperationViewController.h
//  SFToLF
//
//  Created by Harshal Joshi on 12/28/15.
//  Copyright © 2015 Indi-Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchOperationViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchQueryTextField;
@property (weak, nonatomic) IBOutlet UITableView *searchQueryResultTable;

-(IBAction)updateSearchQuery:(id)sender;
@end

