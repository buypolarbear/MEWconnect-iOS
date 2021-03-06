//
//  QRScannerViewInput.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 28/04/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;

@class AVCaptureSession;

@protocol QRScannerViewInput <NSObject>

- (void) setupInitialStateWithCaptureSession:(AVCaptureSession *)captureSession;
- (void) animateVideoPreview;

- (void) showLoading;
- (void) showError;
- (void) showSuccess;
@end
