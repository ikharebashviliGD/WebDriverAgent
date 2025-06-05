/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "XCUIElement+FBMinMax.h"
#import "FBXCElementSnapshotWrapper+Helpers.h"
#import "XCUIElement+FBUtilities.h"
#import "XCTestPrivateSymbols.h"

NSNumber * _Nullable fetchSnapshotMinValue(id<FBXCElementSnapshot> snapshot)
{
  if (nil == snapshot.additionalAttributes) {
    return nil;
  }
  return snapshot.additionalAttributes[FB_XCAXACustomMinValueAttribute];
}

NSNumber * _Nullable fetchSnapshotMaxValue(id<FBXCElementSnapshot> snapshot)
{
  if (nil == snapshot.additionalAttributes) {
    return nil;
  }
  return snapshot.additionalAttributes[FB_XCAXACustomMaxValueAttribute];
}


@implementation XCUIElement (FBMinMax)

- (NSNumber *)fb_minValue
{
  @autoreleasepool {
    id<FBXCElementSnapshot> snapshot = [self fb_standardSnapshot];

    return [FBXCElementSnapshotWrapper ensureWrapped:snapshot].fb_minValue;
  }
}

- (NSNumber *)fb_maxValue
{
  @autoreleasepool {
    id<FBXCElementSnapshot> snapshot = [self fb_standardSnapshot];
    return [FBXCElementSnapshotWrapper ensureWrapped:snapshot].fb_maxValue;
  }
}

@end


@implementation FBXCElementSnapshotWrapper (FBMinMax)

/**
 Returns minValue, caching it in additionalAttributes beforehand, if it has not already been done.
*/
- (NSNumber *)fb_minValue
{
  NSNumber *cached = fetchSnapshotMinValue(self);
  if (nil != cached) {
    return cached;
  }
  
  for (id<FBXCElementSnapshot> descendant in (self._allDescendants ?: @[])) {
    NSNumber *descendantMin = fetchSnapshotMinValue(descendant);
    if (nil != descendantMin) {
      return descendantMin;
    }
  }

  NSError *error = nil;
  NSNumber *attributeValue = [self fb_attributeValue:FB_XCAXACustomMinValueAttributeName
                                              error:&error];
  if (nil != attributeValue) {
    NSMutableDictionary *updated = [NSMutableDictionary dictionaryWithDictionary:self.additionalAttributes ?: @{}];
    updated[FB_XCAXACustomMinValueAttribute] = attributeValue;
    self.snapshot.additionalAttributes = updated.copy;
    return attributeValue;
  }

  NSLog(@"Cannot determine minValue of %@ natively: %@. Defaulting to nil", self.fb_description, error.description);
  return nil;
}

- (NSNumber *)fb_maxValue
{
  NSNumber *cached = fetchSnapshotMaxValue(self);
  if (nil != cached) {
    return cached;
  }

  for (id<FBXCElementSnapshot> descendant in (self._allDescendants ?: @[])) {
    NSNumber *descendantMax = fetchSnapshotMaxValue(descendant);
    if (nil != descendantMax) {
      return descendantMax;
    }
  }

  NSError *error = nil;
  NSNumber *attributeValue = [self fb_attributeValue:FB_XCAXACustomMaxValueAttributeName
                                              error:&error];
  if (nil != attributeValue) {
    NSMutableDictionary *updated = [NSMutableDictionary dictionaryWithDictionary:self.additionalAttributes ?: @{}];
    updated[FB_XCAXACustomMaxValueAttribute] = attributeValue;
    self.snapshot.additionalAttributes = updated.copy;
    return attributeValue;
  }

  NSLog(@"Cannot determine maxValue of %@ natively: %@. Defaulting to nil", self.fb_description, error.description);
  return nil;
}

@end
