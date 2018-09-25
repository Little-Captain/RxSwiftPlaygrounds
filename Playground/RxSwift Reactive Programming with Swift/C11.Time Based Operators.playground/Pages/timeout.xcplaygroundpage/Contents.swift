import UIKit
import RxSwift
import RxCocoa

// Support code -- DO NOT REMOVE
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
  static func make() -> TimelineView<E> {
    return TimelineView(width: 400, height: 100)
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

// timeout
// Its primary purpose is to semantically distinguish an actual timer from
// a timeout (error) condition. Therefore, when a timeout operator fires,
// it emits an RxError.TimeoutError error event; if not caught, it terminates
// the sequence.
// 它的主要目的是为了语义上区分实际定时器和超时条件.
// 因此, 当超时运算符启动, 它发出一个 RxError.TimeoutError 错误事件,
// 如果没有被捕获, 整个序列异常终止

// An alternate version of timeout(_:scheduler:) takes an observable and,
// when the timeout fires, switches the subscription to this observable
// instead of emitting an error. There are many uses for this form of timeout,
// one of which is to emit a value (instead of an error) then complete normally.
// 一个可选的 timeout(_:scheduler:) 版本就是传入一个 observable,
// 然后当超时触发, 订阅被切换到这个 observable 而不是发出错误.
// 这是使用 timeout 操作符的常见形式, 它会发出值(而不是错误), 然后正常结束.

let button = UIButton(type: .system)
button.setTitle("Press me now!", for: .normal)
button.sizeToFit()

let tapsTimeline = TimelineView<String>.make()
let stack = UIStackView.makeVertical([
    button,
    UILabel.make("Taps on button above"),
    tapsTimeline])

_ = button
    .rx
    .tap
    .map { _ in "•" }
    .timeout(5, scheduler: MainScheduler.instance)
//    .timeout(5, other: Observable.just("X"), scheduler: MainScheduler.instance)
    .subscribe(tapsTimeline)

let hostView = setupHostView()
hostView.addSubview(stack)
hostView
