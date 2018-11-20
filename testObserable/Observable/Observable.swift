//
//  Observable.swift
//  MXOne
//
//  Created by Riadh on 3/3/16.
//  Copyright © 2016 aigens. All rights reserved.
//

import Foundation

protocol AnyObserver: class {
    func remove()
}

struct ObserverOptions: OptionSet {
    typealias RawValue = Int
    let rawValue: Int
    // 如果連續執行, 只執行最後一個,默認方式,也是建議的
    static let Coalescing = ObserverOptions(rawValue: 1)
    // 同步執行, 會等上一個執行完成才執行下一個
    static let FireSynchronously = ObserverOptions(rawValue: 1 << 1)
    // 立即執行, 會監聽到最開始的賦值, 不會等上一個執行完成才執行下一個
    static let FireImmediately = ObserverOptions(rawValue: 1 << 2)
}

//MARK: Observer
class Observer<Value> {
    typealias ActionType = (_ oldValue: Value, _ newValue: Value) -> Void
    let action: ActionType
    let queue: OperationQueue
    let options: ObserverOptions
    fileprivate var coalescedOldValue: Value?
    fileprivate var fireCount = 0
    fileprivate weak var observable: Observable<Value>?

    init(queue: OperationQueue = OperationQueue.main,
        options: ObserverOptions = [.Coalescing],
        action: @escaping ActionType) {
        self.action = action
        self.queue = queue

        var optionsCopy = options
        if optionsCopy.contains(ObserverOptions.FireSynchronously) {
            optionsCopy.remove(.Coalescing)
        }
        self.options = optionsCopy
    }

    func fire(_ oldValue: Value, newValue: Value) {
        fireCount += 1
        let count = fireCount
        if options.contains(.Coalescing) && coalescedOldValue == nil {
            coalescedOldValue = oldValue
        }

        let operation = BlockOperation(block: { () -> Void in
            if self.options.contains(.Coalescing) {
                guard count == self.fireCount else { return }
                self.action(self.coalescedOldValue ?? oldValue, newValue)
                self.coalescedOldValue = nil
            } else {
                self.action(oldValue, newValue)
            }
        })
        queue.addOperations([operation], waitUntilFinished: self.options.contains(.FireSynchronously))
    }


}

extension Observer: AnyObserver {
    func remove() {
        observable?.removeObserver(self)
    }
}

protocol ObservableType {
    associatedtype ValueType
    var value: ValueType { get }
    func addObserver(_ observer: Observer<ValueType>)
    func removeObserver(_ observer: Observer<ValueType>)
}

extension ObservableType {
    @discardableResult func onSet(_ options: ObserverOptions = [.Coalescing],
        action: @escaping (ValueType, ValueType) -> Void) -> Observer<ValueType> {
        let observer = Observer<ValueType>(options: options, action: action)
        addObserver(observer)
        return observer
    }
}

class Observable<Value> {
    var value: Value {
        didSet {
            privateQueue.async {
                for observer in self.observers {
                    observer.fire(oldValue, newValue: self.value)
                }
            }
        }
    }
    fileprivate let privateQueue = DispatchQueue(label: "Observable Global Queue", attributes: [])
    fileprivate var observers: [Observer<Value>] = []
    init(_ value: Value) {
        self.value = value
    }
}

extension Observable: ObservableType {
    typealias ValueType = Value
    func addObserver(_ observer: Observer<ValueType>) {
        privateQueue.sync {
            self.observers.append(observer)
        }
        if observer.options.contains(.FireImmediately) {
            observer.fire(value, newValue: value)
        }
    }

    func removeObserver(_ observer: Observer<ValueType>) {
        privateQueue.sync {
            guard let index = self.observers.index(where: { observer === $0 }) else { return }
            self.observers.remove(at: index)
        }
    }
}


