//
//  StartModuleInput.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 14/04/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;
@import ViperMcFlurry;

@protocol StartModuleInput <RamblerViperModuleInput>
- (void) configureModule;
- (void) configurateForCreatedWalletWithAddress:(NSString *)address;
@end
