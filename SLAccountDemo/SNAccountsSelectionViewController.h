@class ACAccount;

@interface SNAccountsSelectionViewController : UITableViewController
@property (strong, nonatomic) NSArray *accounts;
@property (copy, nonatomic) void (^didPickAccount)(SNAccountsSelectionViewController *viewController, ACAccount *account);
@end
