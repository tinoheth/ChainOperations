//
//  FailableOperation.swift
//  ChainOperation
//
//  Created by Tino Heth on 10.03.16.
//  Copyright © 2016 t-no. All rights reserved.
//

import UIKit

public class ChainOperation<Result>: NSOperation {
	public var result: Result?
	public var error: ErrorType?

	public final var failed: Bool {
		return error != nil
	}

	override public var fulfilled: Bool {
		return !self.failed && super.fulfilled
	}

	var requirements = Array<RequirementType>()

	private final func handleRequirements() {
		for requirement in requirements {
			if !requirement.fulfilled {
				cancel()
			}
			for op in requirement.linkedOperations {
				self.removeDependency(op)
			}
		}
		requirements.removeAll()
	}

	override public final func main() {
		handleRequirements()
		if !cancelled {
			self.result = execute()
		}
	}

	public func execute() -> Result? {
		return nil
	}
}

private enum StateName: String {
	case finished, executing
}

public class ConcurrentChainOperation<Result>: ChainOperation<Result> {

	override public var concurrent: Bool {
		return true
	}

	private var isFinished: Bool = false {
		willSet {
			self.willChangeValueForKey(StateName.finished.rawValue)
		}
		didSet {
			self.didChangeValueForKey(StateName.finished.rawValue)
		}
	}
	override public var finished: Bool {
		return isFinished
	}

	private var isExecuting: Bool = false {
		willSet {
			self.willChangeValueForKey(StateName.executing.rawValue)
		}
		didSet {
			self.didChangeValueForKey(StateName.executing.rawValue)
		}
	}
	override public var executing: Bool {
		return isExecuting
	}

	public override func start() {
		handleRequirements()
		if !cancelled {
			self.isExecuting = true
			execute()
		} else {
			self.isFinished = true
		}
	}

	public func signalFinish() {
		self.isExecuting = false
		self.isFinished = true
	}
}