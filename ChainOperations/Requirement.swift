//
//  Created by Tino Heth on 10.03.16.
//  Copyright © 2016 t-no. All rights reserved.
//

import Foundation

public protocol RequirementType {
	var fulfilled: Bool { get }
	var linkedOperations: [NSOperation] { get }
}

extension NSOperation: RequirementType {
	public var fulfilled: Bool {
		return !self.cancelled
	}

	public var linkedOperations: [NSOperation] {
		return [self]
	}
}