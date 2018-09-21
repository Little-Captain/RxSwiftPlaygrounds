//: Playground - noun: a place where people can play

import RxSwift

func example(_ description: String,
             _ action: () -> ()) {
    
    print("================== \(description) ==================")
    action()
}

public func delay(_ delay: Double,
                  closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}

// 为什么需要connectable operator

// 模拟表单提交
example("模拟表单提交") {
    
    let supervisor = PublishSubject<Int>()
    let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance).multicast(supervisor)
    
    
    _ = supervisor.subscribe(onNext: {
        print("Supervisor: event \($0)") })
    
    _  = interval.subscribe(onNext: {
        print("\tSubscriber 1: \($0)") })
    
    _ = interval.connect()
    
    delay(2) {
        _  = interval.subscribe(onNext: {
            print("\tSubscriber 2: \($0)") })
    }
    
    delay(4) {
        _  = interval.subscribe(onNext: {
            print("\tSubscriber 3: \($0)") })
    }
    
    
    dispatchMain()
}
