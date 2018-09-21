//: Playground - noun: a place where people can play

import Foundation
import RxSwift

// Observable中的每一个元素，都可以理解为一个异步发生的事件
let evenNumberObservable = Observable.of("1", "2", "3", "4", "5", "6", "7", "8", "9")
    .map { Int($0) }
    .filter {
        if let item = $0, item % 2 == 0 {
            print("Even: \(item)")
            return true
        }
        
        return false
}

evenNumberObservable.subscribe { event in
    print("Event: \(event)")
}
evenNumberObservable.skip(2).subscribe { event in
    print("Event: \(event)")
}

public func delay(_ delay: Double,
                  closure: @escaping () -> ()) {
    
    DispatchQueue.main.asyncAfter(
    deadline: .now() + delay) {
        closure()
    }
}

var bag = DisposeBag()

Observable<Int>.interval(1, scheduler: MainScheduler.instance)
    .subscribe(
        onNext: { print("Subscribed: \($0)") },
        onDisposed: { print("The queue was disposed.") })
    .disposed(by: bag)

delay(5) {
    bag = DisposeBag()
}

dispatchMain()
