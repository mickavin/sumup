#import <React/RCTBridgeModule.h>
#import "RNSumUpBridge.h"

@interface RCT_EXTERN_MODULE(RNSumUp, NSObject)

RCT_EXTERN_METHOD(RNSumUp:(NSString *)message resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

@end
