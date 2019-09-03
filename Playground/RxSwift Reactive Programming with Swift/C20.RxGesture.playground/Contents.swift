//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import RxCocoa
import RxGesture

//: RxGesture

let bag = DisposeBag()

let view = UIView(frame: CGRect(x: 200, y: 200, width: 50, height: 50))
view.backgroundColor = .red

view
    .rx.tapGesture()
    .when(.recognized)
    .asLocation(in: .superview)
    .subscribe(onNext: {
        print("view tapped \($0)")
    })
    .disposed(by: bag)

view
    .rx.anyGesture(.tap(), .longPress())
    .when(.recognized)
    .subscribe(onNext: { [weak view] gesture in
        if let tap = gesture as? UITapGestureRecognizer {
            print("view was tapped at \(tap.location(in: view!))")
        } else {
            print("view was long pressed")
        }
    })
    .disposed(by: bag)

view
    .rx.screenEdgePanGesture(edges: [.top, .bottom])
    .when(.recognized)
    .subscribe(onNext: { recognizer in
        print("\(recognizer) 被识别")
    })
    .disposed(by: bag)

view
    .rx.swipeGesture(.left, configuration: { recognizer, _ in
        // 配置手势识别器
        recognizer.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.stylus.rawValue)]
    })

let vForPan = UIView(frame: CGRect(x: 300, y: 200, width: 50, height: 50))
vForPan.backgroundColor = .yellow

vForPan
    .rx.panGesture()
    .asTranslation(in: .view)
    .subscribe(onNext: { translation, velocity in
        print("Translation=\(translation), velocity=\(velocity)")
    })
    .disposed(by: bag)

let vForRot = UIView(frame: CGRect(x: 200, y: 300, width: 50, height: 50))
vForRot.backgroundColor = .green

vForRot
    .rx.rotationGesture()
    .asRotation()
    .subscribe(onNext: { rotation, velocity in
        print("Rotation=\(rotation), velocity=\(velocity)")
    })
    .disposed(by: bag)

let vForAutomated = UIView(frame: CGRect(x: 300, y: 300, width: 50, height: 50))
vForAutomated.backgroundColor = .black

vForAutomated
    .rx.transformGestures()
    .asTransform()
    .subscribe(onNext: { [unowned vForAutomated] (transform, velocity) in
        vForAutomated.transform = transform
    })
    .disposed(by: bag)

let vForAdvanced = UIView(frame: CGRect(x: 300, y: 400, width: 50, height: 50))
vForAdvanced.backgroundColor = .cyan

let gesture = vForAdvanced
    .rx.longPressGesture()
    .share(replay: 1, scope: .whileConnected)

gesture
    .when(.began)
    .subscribe(onNext: {
        print("long press \($0)")
    })
    .disposed(by: bag)

gesture
    .when(.ended)
    .subscribe(onNext: {
        print("Done panning \($0)")
    })
    .disposed(by: bag)

let hostView = setupHostView()
hostView.addSubview(view)
hostView.addSubview(vForPan)
hostView.addSubview(vForRot)
hostView.addSubview(vForAutomated)
hostView.addSubview(vForAdvanced)
hostView
