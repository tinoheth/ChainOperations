//
//  Created by Tino Heth on 10.03.16.
//  Copyright © 2016 t-no. All rights reserved.
//

import Foundation

public class ChainableOperation: NSOperation {
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
}

private class ResultBox<T> {
	var content: T
	init(content: T) {
		self.content = content
	}
}

public class ResultOperation<Result>: ChainableOperation {
	private var resultBox: ResultBox<Result>?
	public var result: Result? {
		set(value) {
			if let value = value {
				resultBox = ResultBox(content: value)
			} else {
				resultBox = nil
			}
		}
		get {
			return resultBox?.content
		}
	}
}

public class ChainOperation<Result>: ResultOperation<Result> {
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
	case isFinished, isExecuting
}

public class ConcurrentChainOperation<Result>: ResultOperation<Result> {

	override public var concurrent: Bool {
		return true
	}

	private var isFinished: Bool = false {
		willSet {
			self.willChangeValueForKey(StateName.isFinished.rawValue)
		}
		didSet {
			self.didChangeValueForKey(StateName.isFinished.rawValue)
		}
	}
	override public var finished: Bool {
		return isFinished
	}

	private var isExecuting: Bool = false {
		willSet {
			self.willChangeValueForKey(StateName.isExecuting.rawValue)
		}
		didSet {
			self.didChangeValueForKey(StateName.isExecuting.rawValue)
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

	public func execute() {
		signalFinish()
	}

	public func signalFinish() {
		self.isExecuting = false
		self.isFinished = true
	}

	override init() {
		super.init()
	}
}