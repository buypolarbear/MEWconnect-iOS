//
//  SplashPasswordAssembly.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 26/05/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import ViperMcFlurry;

#import "TransitioningDelegateFactory.h"
#import "ServiceComponents.h"

#import "SplashPasswordAssembly.h"

#import "SplashPasswordViewController.h"
#import "SplashPasswordInteractor.h"
#import "SplashPasswordPresenter.h"
#import "SplashPasswordRouter.h"

@implementation SplashPasswordAssembly

- (SplashPasswordViewController *)viewSplashPassword {
  return [TyphoonDefinition withClass:[SplashPasswordViewController class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(output)
                                                with:[self presenterSplashPassword]];
                          [definition injectProperty:@selector(moduleInput)
                                                with:[self presenterSplashPassword]];
                          [definition injectProperty:@selector(customTransitioningDelegate)
                                                with:[self.transitioningDelegateFactory transitioningDelegateWithType:@(TransitioningDelegateBottomBackgroundedModal) cornerRadius:@16.0]];
                          [definition injectProperty:@selector(modalPresentationStyle)
                                                with:@(UIModalPresentationCustom)];
                        }];
}

- (SplashPasswordInteractor *)interactorSplashPassword {
  return [TyphoonDefinition withClass:[SplashPasswordInteractor class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(output)
                                                with:[self presenterSplashPassword]];
                          [definition injectProperty:@selector(cryptoService)
                                                with:[self.serviceComponents MEWCrypto]];
                        }];
}

- (SplashPasswordPresenter *)presenterSplashPassword{
  return [TyphoonDefinition withClass:[SplashPasswordPresenter class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(view)
                                                with:[self viewSplashPassword]];
                          [definition injectProperty:@selector(interactor)
                                                with:[self interactorSplashPassword]];
                          [definition injectProperty:@selector(router)
                                                with:[self routerSplashPassword]];
                        }];
}

- (SplashPasswordRouter *)routerSplashPassword{
  return [TyphoonDefinition withClass:[SplashPasswordRouter class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(transitionHandler)
                                                with:[self viewSplashPassword]];
                        }];
}

@end
