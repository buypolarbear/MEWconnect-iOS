//
//  TransactionInteractor.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 28/04/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

#import "TransactionInteractorInput.h"

@protocol TransactionInteractorOutput;

@protocol MEWCrypto;
@protocol MEWConnectFacade;

@interface TransactionInteractor : NSObject <TransactionInteractorInput>
@property (nonatomic, weak) id<TransactionInteractorOutput> output;
@property (nonatomic, strong) id <MEWCrypto> cryptoService;
@property (nonatomic, strong) id <MEWConnectFacade> connectFacade;
@end
