#import "SNAccountsSelectionViewController.h"
#import "SNAccountViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface SNAccountViewController () <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)connectWithFacebook:(id)sender;
- (IBAction)connectWithTwitter:(id)sender;

@property (strong, nonatomic) NSMutableDictionary *accounts;
@property (strong, nonatomic) NSDictionary *socialSiteNames;
@property (strong, nonatomic) NSIndexPath *willDeleteIndexPath;
@end

@implementation SNAccountViewController

- (id)init {
  self = [self initWithNibName:@"SNAccountViewController" bundle:nil];
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.accounts = [NSMutableDictionary dictionary];
  self.accounts[ACAccountTypeIdentifierFacebook] = [NSMutableArray array];
  self.accounts[ACAccountTypeIdentifierTwitter] = [NSMutableArray array];
  self.socialSiteNames = @{
    ACAccountTypeIdentifierFacebook : @"Facebook",
    ACAccountTypeIdentifierTwitter: @"Twitter"
  };
  [self.tableView registerNib:[UINib nibWithNibName:@"SNAccountCell" bundle:nil]
       forCellReuseIdentifier:@"SNAccountCell"];
  [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (IBAction)connectWithFacebook:(id)sender {
  __weak SNAccountViewController *weakSelf = self;
  NSDictionary *readOptions = @{
    ACFacebookAppIdKey: @"129125047131390",
    ACFacebookPermissionsKey: @[@"user_about_me", @"email"],
    ACFacebookAudienceKey: ACFacebookAudienceFriends
  };
  [self connectToAccountTypeIdentifier:ACAccountTypeIdentifierFacebook options:readOptions completion:^(ACAccount *pickedAccount, NSError *error) {
     if (pickedAccount) {
       NSDictionary *writeOptions = @{
         ACFacebookAppIdKey: @"129125047131390",
         ACFacebookPermissionsKey: @[@"publish_stream", @"publish_actions"],
         ACFacebookAudienceKey: ACFacebookAudienceFriends
       };
       [self connectToAccountTypeIdentifier:ACAccountTypeIdentifierFacebook options:writeOptions completion:^(ACAccount *pickedAccount1, NSError *error1) {
          if (pickedAccount1) {
            [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
          }
        }];
     }
  }];
}

- (IBAction)connectWithTwitter:(id)sender {
  __weak SNAccountViewController *weakSelf = self;
  [self connectToAccountTypeIdentifier:ACAccountTypeIdentifierTwitter options:nil completion:^(ACAccount *pickedAccount, NSError *error) {
    if (pickedAccount) {
      [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    }
  }];
}

- (void)connectToAccountTypeIdentifier:(NSString *)accountTypeIdentifier options:(NSDictionary *)connectOptions completion:(void (^)(ACAccount *pickedAccount, NSError *error))completion {
  __weak SNAccountViewController *weakSelf = self;
  
  ACAccountStore *accountStore = [[ACAccountStore alloc] init];
  ACAccountType *accountType = [accountStore
                                accountTypeWithAccountTypeIdentifier:accountTypeIdentifier];
  [accountStore requestAccessToAccountsWithType:accountType options:connectOptions completion:^(BOOL granted, NSError *error) {

    if (granted) {
      NSArray *accounts = [accountStore accountsWithAccountType:accountType];

      if (accounts.count == 1) {
        ACAccount *pickedAccount = [accounts lastObject];
        for (ACAccount *storedAccount in weakSelf.accounts[accountTypeIdentifier]) {
          if ([storedAccount.username isEqualToString:pickedAccount.username]) {
            [weakSelf.accounts[accountTypeIdentifier] removeObject:storedAccount];
            break;
          }
        }
        [weakSelf.accounts[accountTypeIdentifier] insertObject:pickedAccount atIndex:0];
        if (completion) completion(pickedAccount, error);

      } else {
        SNAccountsSelectionViewController *vc = [[SNAccountsSelectionViewController alloc] initWithStyle:UITableViewStyleGrouped];
        vc.title = [NSString stringWithFormat:@"Pick a %@ Account", weakSelf.socialSiteNames[accountTypeIdentifier]];
        vc.accounts = accounts;
        vc.didPickAccount = ^(SNAccountsSelectionViewController *viewController, ACAccount *account) {
          if (account) {
            for (ACAccount *storedAccount in weakSelf.accounts[accountTypeIdentifier]) {
              if ([storedAccount.username isEqualToString:account.username]) {
                [weakSelf.accounts[accountTypeIdentifier] removeObject:storedAccount];
                break;
              }
            }
            [weakSelf.accounts[accountTypeIdentifier] insertObject:account atIndex:0];
          }
          [viewController dismissViewControllerAnimated:YES completion:nil];
          if (completion) completion(account, nil);
        };
        [weakSelf presentViewController:vc animated:YES completion:nil];
      }


    } else {
      if (completion) completion(nil, error);
    }
  }];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return self.socialSiteNames[self.socialSiteNames.allKeys[section]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.accounts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSString *key = self.accounts.allKeys[section];
  return [self.accounts[key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SNAccountCell"];
  NSString *key = self.accounts.allKeys[indexPath.section];
  ACAccount *account = self.accounts[key][indexPath.row];
  cell.textLabel.text = account.username;
  cell.detailTextLabel.text = self.socialSiteNames[key];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  self.willDeleteIndexPath = indexPath;
  UIActionSheet *confirmationSheet = [[UIActionSheet alloc] initWithTitle:@"Confirm disconnect account" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Disconnect" otherButtonTitles:nil];
  [confirmationSheet showInView:self.view];
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    NSString *key = self.accounts.allKeys[self.willDeleteIndexPath.section];
    [self.accounts[key] removeObjectAtIndex:self.willDeleteIndexPath.row];
  }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    [self.tableView deleteRowsAtIndexPaths:@[self.willDeleteIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
  }
  self.willDeleteIndexPath = nil;
}

@end
