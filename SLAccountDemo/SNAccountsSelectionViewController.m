#import <Accounts/Accounts.h>
#import "SNAccountsSelectionViewController.h"

@interface SNAccountsSelectionViewController ()
@end

@implementation SNAccountsSelectionViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.tableView registerNib:[UINib nibWithNibName:@"SNAccountCell" bundle:nil]
       forCellReuseIdentifier:@"SNAccountCell"];
  [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return self.title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SNAccountCell"];
  ACAccount *account = self.accounts[indexPath.row];
  cell.textLabel.text = account.username;
  cell.detailTextLabel.text = nil;
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (self.didPickAccount) self.didPickAccount(self, self.accounts[indexPath.row]);
}

@end
