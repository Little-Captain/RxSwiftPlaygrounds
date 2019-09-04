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

// 为什么需要 connectable operator

// 模拟表单提交
example("模拟表单提交") {
    let supervisor = PublishSubject<Int>()
    let interval = Observable<Int>
        .interval(1, scheduler: MainScheduler.instance)
        .multicast(supervisor)
    
    _ = supervisor.subscribe(onNext: {
        print("Supervisor: event \($0)")
    })
    
    let disposable1 = interval.subscribe(onNext: {
        print("\tSubscriber 1: \($0)")
    })
    
    let disposable = interval.connect()
    
    
    var disposable2: Disposable?
    delay(2) {
        disposable2 = interval.subscribe(onNext: {
            print("\tSubscriber 2: \($0)")
        })
    }
    
    delay(4) {
        _ = interval.subscribe(onNext: {
            print("\tSubscriber 3: \($0)")
        })
    }
    
    delay(6) {
        disposable1.dispose()
    }
    
    delay(8) {
        disposable2?.dispose()
    }
    
    delay(10) {
        disposable.dispose()
    }
    
    delay(12) {
        _ = interval.subscribe(onNext: {
            print("\tSubscriber 4: \($0)")
        })
        
        _ = interval.connect()
    }
    
    
    dispatchMain()
}
