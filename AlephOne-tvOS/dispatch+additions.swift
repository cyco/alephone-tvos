//
//  dispatch+additions.swift
//  AlephOne-tvOS
//
//  Created by Christoph Leimbrock on 08/07/16.
//  Copyright © 2016 chris. All rights reserved.
//

import Foundation

public func dispatch_in(nsecs:UInt64, _ queue:dispatch_queue_t, _ block: dispatch_block_t) -> Void {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(nsecs)), queue, block)
}