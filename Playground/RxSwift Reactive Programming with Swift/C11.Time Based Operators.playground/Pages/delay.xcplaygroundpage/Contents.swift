import UIKit
import RxSwift
import RxCocoa

// Support code -- DO NOT REMOVE
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
    static func make() -> TimelineView<E> {
        let view = TimelineView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
        view.setup()
        return view
    }
    public func on(_ event: Event<E>) {
        switch event {
        case .next(let value):
            add(.Next(String(describing: value)))
        case .completed:
            add(.Completed())
        case .error(_):
            add(.Error())
        }
    }
}

let elementsPerSecond = 1
let delayInSeconds = 1.5

let sourceObservable = PublishSubject<Int>()

let sourceTimeline = TimelineView<Int>.make()
let delayedTimeline = TimelineView<Int>.make()

let stack = UIStackView.makeVertical([
  UILabel.makeTitle("delay"),
  UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
  sourceTimeline,
  UILabel.make("Delayed elements (with a \(delayInSeconds)s delay):"),
  delayedTimeline])

var current = 1
let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
  sourceObservable.onNext(current)
  current = current + 1
}

//: Time-shifting operators
// Delayed subscriptions
// The idea behind the delaySubscription(_:scheduler:) is, as the name implies,
// to delay the time a subscriber starts receiving elements from its subscription.
// In the right timeline view, you can observe that the second timeline starts
// picking up elements after the delay specified by delayInSeconds.
// delaySubscription(_:scheduler:) 的目的是延迟订阅者从订阅中开始接收元素的时间

// Note: In Rx, some observables are called “cold” while others are “hot”.
// Cold observables start emitting elements when you subscribe to them.
// Hot observables are more like permanent sources you happen to look at
// at some point (think of Notifications). When delaying a subscription,
// it won't make a difference if the observable is cold. If it's hot,
// you may skip elements, as in this example.
// Hot and cold observables are a tricky topic that can take some time
// getting your head around. Remember that cold observables emit events
// only when subscribed to, but hot observables emit events independent
// of being subscribed to.
// 注意: 在 Rx 中, 一些 observable 称为 `cold` 的, 另一些称为 `hot` 的
// cold observable 在你订阅它的时候发出元素
// hot observable 更像是一个永久的源, 一直发出元素, 你可以随时观察它 (就像通知)
// 当延迟一个订阅, 如果是 cold observable,

// cold observable
_ = Observable.from([1, 2, 3, 4])
    .delaySubscription(RxTimeInterval(delayInSeconds), scheduler: MainScheduler.instance)
    .subscribe(onNext: { print($0) })

_ = sourceObservable.subscribe(sourceTimeline)

// Setup the delayed subscription
// hot observable
_ = sourceObservable
//    .delaySubscription(RxTimeInterval(delayInSeconds), scheduler: MainScheduler.instance)
    .delay(RxTimeInterval(delayInSeconds), scheduler: MainScheduler.instance)
    .subscribe(delayedTimeline)

let hostView = setupHostView()
hostView.addSubview(stack)
hostView
