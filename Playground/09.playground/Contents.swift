//: Playground - noun: a place where people can play

import RxSwift

func example(_ description: String,
             _ action: () -> ()) {
    
    print("================== \(description) ==================")
    action()
}

// 如何在不同的Observables之间跳转

// 模拟表单提交
example("模拟表单提交") {
    
    let textField = BehaviorSubject<String>(value: "boxu")
    let submitBtn = PublishSubject<Void>()
    
    let bag = DisposeBag()
    
    submitBtn.withLatestFrom(textField).subscribe(onNext: {
        dump($0)
    }).disposed(by: bag)
    
    submitBtn.onNext(())
    textField.onNext("boxue")
    submitBtn.onNext(())
}

// 在多个Observables之间进行跳转
example("在多个Observables之间进行跳转") {
    
    let coding = PublishSubject<String>()
    let testing = PublishSubject<String>()
    let working = PublishSubject<Observable<String>>()
    
    let bag = DisposeBag()
    
    working.switchLatest().subscribe(onNext: { dump($0) }).disposed(by: bag)
    
//    working.onNext(coding)
//    coding.onNext("version1")
//
//    working.onNext(testing)
//    testing.onNext("FAILED")
//
//    working.onNext(coding)
//    coding.onNext("version1")
//
//    working.onNext(testing)
//    testing.onNext("PASS")
    
    working.onNext(coding)
    coding.onNext("version1")
    
    working.onNext(testing)
    testing.onNext("FAILED")
    
    coding.onNext("version2") // Cannot subscribe this event
}
