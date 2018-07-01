//
//  HomeInteractor.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 28/04/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import libextobjc.EXTScope;

#import "HomeInteractor.h"

#import "TokensService.h"

#import "MEWConnectFacade.h"
#import "MEWConnectFacadeConstants.h"
#import "MEWConnectCommand.h"
#import "Ponsomizer.h"
#import "BlockchainNetworkService.h"
#import "AccountsService.h"

#import "CacheRequest.h"
#import "CacheTracker.h"

#import "NetworkPlainObject.h"
#import "AccountPlainObject.h"
#import "TokenModelObject.h"

#import "HomeInteractorOutput.h"

@interface HomeInteractor ()
@property (nonatomic, strong) AccountPlainObject *account;
@end

@implementation HomeInteractor

- (void)dealloc {
  [self unsubscribe];
}

#pragma mark - HomeInteractorInput

- (void) configurate {
  if (!self.account) {
    [self refreshAccount];
  }
  [self _reloadCacheRequest];
  [self reloadData];
}

- (void)reloadData {
  if (!self.account) {
    [self refreshAccount];
    return;
  }
  @weakify(self);
  [self.accountService updateBalanceForAccount:self.account
                                withCompletion:^(NSError *error) {
                                  if (!error) {
                                    @strongify(self);
                                    [self.output didUpdateEthereumBalance];
                                  }
                                }];
  [self.tokensService updateTokenBalancesForAccount:self.account
                                     withCompletion:^(NSError *error) {
                                       if (!error) {
                                         @strongify(self);
                                         [self.output didUpdateTokens];
                                       }
                                     }];
}

- (void) refreshAccount {
  AccountModelObject *accountModelObject = [self.accountService obtainActiveAccount];
  NSArray *ignoringProperties = @[NSStringFromSelector(@selector(tokens)),
                                  NSStringFromSelector(@selector(active)),
                                  NSStringFromSelector(@selector(accounts))];
  AccountPlainObject *account = [self.ponsomizer convertObject:accountModelObject ignoringProperties:ignoringProperties];
  BOOL refreshCacheRequest = self.account && ![account isEqualToAccount:self.account];
  self.account = account;
  if (refreshCacheRequest) {
    [self _reloadCacheRequest];
  }
}

- (AccountPlainObject *) obtainAccount {
  return self.account;
}

- (NSUInteger) obtainNumberOfTokens {
  return [self.tokensService obtainNumberOfTokensForAccount:self.account];
}

- (void)subscribe {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MEWConnectDidConnect:) name:MEWConnectFacadeDidConnectNotification object:self.connectFacade];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MEWConnectDidDisconnect:) name:MEWConnectFacadeDidDisconnectNotification object:self.connectFacade];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MEWConnectDidReceiveMessage:) name:MEWConnectFacadeDidReceiveMessageNotification object:self.connectFacade];
  
}

- (void)unsubscribe {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) searchTokensWithTerm:(NSString *)term {
  if ([term length] > 0) {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.name contains[cd] %@ || SELF.symbol contains[cd] %@) && SELF.address != nil", term, term];
    [self.cacheTracker filterResultsWithPredicate:predicate];
  } else {
    [self.cacheTracker filterResultsWithPredicate:[NSPredicate predicateWithFormat:@"SELF.address != nil"]];
  }
  CacheTransactionBatch *searchBatch = [self.cacheTracker obtainTransactionBatchFromCurrentCache];
  [self.output didProcessCacheTransaction:searchBatch];
}

- (void)disconnect {
  [self.connectFacade disconnect];
}

- (BOOL)isConnected {
  return [self.connectFacade connectionStatus] == MEWConnectStatusConnected;
}

#pragma mark - Notifications

- (void) MEWConnectDidConnect:(NSNotification *)notification {
  [self.output mewConnectionStatusChanged];
}

- (void) MEWConnectDidDisconnect:(NSNotification *)notification {
  [self.output mewConnectionStatusChanged];
}

- (void) MEWConnectDidReceiveMessage:(NSNotification *)notification {
  MEWConnectCommand *command = notification.userInfo[kMEWConnectFacadeMessage];
  switch (command.type) {
    case MEWConnectCommandTypeSignMessage: {
      [self.output openMessageSignerWithMessage:command];
      break;
    }
    case MEWConnectCommandTypeSignTransaction: {
      [self.output openTransactionSignerWithMessage:command account:self.account];
      break;
    }
      
    default:
      break;
  }
}

#pragma mark - CacheTrackerDelegate

- (void) didProcessTransactionBatch:(CacheTransactionBatch *)transactionBatch {
  [self.output didProcessCacheTransaction:transactionBatch];
}

#pragma mark - Private

- (void) _reloadCacheRequest {
  CacheRequest *request = [CacheRequest requestWithPredicate:[NSPredicate predicateWithFormat:@"SELF.fromAccount.publicAddress == %@", self.account.publicAddress]
                                             sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(name)) ascending:YES]]
                                                 objectClass:[TokenModelObject class]
                                                 filterValue:nil];
  [self.cacheTracker setupWithCacheRequest:request];
  CacheTransactionBatch *initialBatch = [self.cacheTracker obtainTransactionBatchFromCurrentCache];
  [self.output didProcessCacheTransaction:initialBatch];
}

@end