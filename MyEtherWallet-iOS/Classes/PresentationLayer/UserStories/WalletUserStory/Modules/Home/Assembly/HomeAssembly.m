//
//  HomeAssembly.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 28/04/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import ViperMcFlurry;

#import "FetchedResultsControllerAssembly.h"
#import "PonsomizerAssembly.h"

#import "ServiceComponents.h"

#import "HomeAssembly.h"

#import "HomeViewController.h"
#import "HomeInteractor.h"
#import "HomePresenter.h"
#import "HomeRouter.h"
#import "HomeDataDisplayManager.h"
#import "HomeCellObjectBuilder.h"
#import "HomeTableViewAnimator.h"

#import "CacheTracker.h"

@implementation HomeAssembly

- (HomeViewController *)viewHome {
  return [TyphoonDefinition withClass:[HomeViewController class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(output)
                                                with:[self presenterHome]];
                          [definition injectProperty:@selector(moduleInput)
                                                with:[self presenterHome]];
                          [definition injectProperty:@selector(dataDisplayManager)
                                                with:[self dataDisplayManagerHome]];
                          [definition injectProperty:@selector(tableViewAnimator)
                                                with:[self tableViewAnimatorHome]];
                        }];
}

- (HomeInteractor *)interactorHome {
  return [TyphoonDefinition withClass:[HomeInteractor class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(output)
                                                with:[self presenterHome]];
                          [definition injectProperty:@selector(connectFacade)
                                                with:[self.serviceComponents MEWConnectFacade]];
                          [definition injectProperty:@selector(cryptoService)
                                                with:[self.serviceComponents MEWCrypto]];
                          [definition injectProperty:@selector(tokensService)
                                                with:[self.serviceComponents tokensService]];
                          [definition injectProperty:@selector(cacheTracker)
                                                with:[self.cacheTrackerAssembly cacheTrackerWithDelegate:[self interactorHome]]];
                          [definition injectProperty:@selector(ponsomizer)
                                                with:[self.ponsomizerAssembly ponsomizer]];
                        }];
}

- (HomePresenter *)presenterHome{
  return [TyphoonDefinition withClass:[HomePresenter class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(view)
                                                with:[self viewHome]];
                          [definition injectProperty:@selector(interactor)
                                                with:[self interactorHome]];
                          [definition injectProperty:@selector(router)
                                                with:[self routerHome]];
                        }];
}

- (HomeRouter *)routerHome{
  return [TyphoonDefinition withClass:[HomeRouter class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(transitionHandler)
                                                with:[self viewHome]];
                        }];
}

- (HomeDataDisplayManager *) dataDisplayManagerHome {
  return [TyphoonDefinition withClass:[HomeDataDisplayManager class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(cellObjectBuilder)
                                                with:[self cellObjectBuilderHome]];
                          [definition injectProperty:@selector(delegate)
                                                with:[self viewHome]];
                        }];
}

- (HomeTableViewAnimator *) tableViewAnimatorHome {
  return [TyphoonDefinition withClass:[HomeTableViewAnimator class]];
}

- (HomeCellObjectBuilder *) cellObjectBuilderHome {
  return [TyphoonDefinition withClass:[HomeCellObjectBuilder class]];
}

@end
