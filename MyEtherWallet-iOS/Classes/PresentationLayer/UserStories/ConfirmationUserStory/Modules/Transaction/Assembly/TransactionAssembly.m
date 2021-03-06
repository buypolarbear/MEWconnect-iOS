//
//  TransactionAssembly.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 28/04/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import ViperMcFlurry;

#import "ServiceComponents.h"

#import "TransactionAssembly.h"

#import "TransactionViewController.h"
#import "TransactionInteractor.h"
#import "TransactionPresenter.h"
#import "TransactionRouter.h"

@implementation TransactionAssembly

- (TransactionViewController *)viewTransaction {
  return [TyphoonDefinition withClass:[TransactionViewController class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(output)
                                                with:[self presenterTransaction]];
                          [definition injectProperty:@selector(moduleInput)
                                                with:[self presenterTransaction]];
                        }];
}

- (TransactionInteractor *)interactorTransaction {
  return [TyphoonDefinition withClass:[TransactionInteractor class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(output)
                                                with:[self presenterTransaction]];
                          [definition injectProperty:@selector(cryptoService)
                                                with:[self.serviceComponents MEWCrypto]];
                          [definition injectProperty:@selector(connectFacade)
                                                with:[self.serviceComponents MEWConnectFacade]];
                        }];
}

- (TransactionPresenter *)presenterTransaction{
  return [TyphoonDefinition withClass:[TransactionPresenter class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(view)
                                                with:[self viewTransaction]];
                          [definition injectProperty:@selector(interactor)
                                                with:[self interactorTransaction]];
                          [definition injectProperty:@selector(router)
                                                with:[self routerTransaction]];
                        }];
}

- (TransactionRouter *)routerTransaction{
  return [TyphoonDefinition withClass:[TransactionRouter class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(transitionHandler)
                                                with:[self viewTransaction]];
                        }];
}

@end
