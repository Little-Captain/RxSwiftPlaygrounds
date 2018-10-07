//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import RxCocoa
import Action

//: Action

let bag = DisposeBag()

// create
// Action<Input, Element>
let buttonAction: Action<Void, Void> = Action {
    print("Doing some work")
    return Observable.create {
        $0.onNext(())
        $0.onCompleted()
        return Disposables.create()
    }
}

let loginAction: Action<(String, String), Bool> = Action {
    let (login, password) = $0
    if login == password {
        return Observable.just(true)
    } else {
        return Observable.just(false)
    }
}

let loginField = UITextField(frame: CGRect(x: 0, y: 30, width: 100, height: 40))
let passwordField = UITextField(frame: CGRect(x: 0, y: 80, width: 100, height: 40))
let loginButton = UIButton(type: .system)
loginButton.frame = CGRect(x: 0, y: 130, width: 40, height: 40)
let loginPasswordObservable = Observable.combineLatest(loginField.rx.text, passwordField.rx.text) { ($0!, $1!) }

loginButton
    .rx.tap
    .withLatestFrom(loginPasswordObservable)
    .bind(to: loginAction.inputs)
    .disposed(by: bag)

loginAction.elements
    .subscribe(onNext: {
        print("登陆 \($0)")
    })
    .disposed(by: bag)

loginAction
    .execute(("123", "1234"))
    .subscribe(onNext: {
        print("执行 \($0)")
    })
    .disposed(by: bag)

loginAction.errors
    .subscribe(onError: { error in
        if case ActionError.underlyingError(let err) = error {
            print("内部错误")
        }
    })
    .disposed(by: bag)

var button = UIButton(type: .contactAdd)
button.rx.action = buttonAction
var count = 1
buttonAction.elements
    .subscribe(onNext: {
        print(count)
        count += 1
    })
    .disposed(by: bag)

let hostView = setupHostView()
hostView.addSubview(button)
hostView.addSubview(loginField)
hostView.addSubview(passwordField)
hostView.addSubview(loginButton)
hostView
