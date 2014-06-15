//
//  Machine+CellHelpers.h
//  PinballMap
//
//  Created by Frank Michael on 4/27/14.
//  Copyright (c) 2014 Frank Michael Sanchez. All rights reserved.
//

#import "Machine.h"

@interface Machine (CellHelpers)

// Returns attributed string with the following format:
// <bold>Machine Name</body> (manufacturer, year)
- (NSAttributedString *)machineTitle;
@end
