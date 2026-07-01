//
//  bridge.h
//  Lithium
//
//  Created by lunginspector on 6/30/26.
//

@import UIKit;

#ifndef bridge_h
#define bridge_h

@interface UIImage (Private)
+ (instancetype)_applicationIconImageForBundleIdentifier:(NSString*)bundleIdentifier format:(int)format scale:(CGFloat)scale;
@end

#endif /* bridge_h */
