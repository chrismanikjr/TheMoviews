//
//  Extension.swift
//  TheMovies
//
//  Created by Chrismanto Manik on 11/19/21.
//

import Foundation
import UIKit

// MARK: - CGSIZE

extension CGSize {
    var scaledSize: CGSize {
        .init(width: width * UIScreen.main.scale, height: height * UIScreen.main.scale)
    }
}

// MARK: - UIIMageView

extension UIImageView {

    var imageSizeAfterAspectFit: CGSize {
        var newWidth: CGFloat
        var newHeight: CGFloat

        guard let image = image else { return frame.size }

        if image.size.height >= image.size.width {
            newHeight = frame.size.height
            newWidth = ((image.size.width / (image.size.height)) * newHeight)

            if CGFloat(newWidth) > (frame.size.width) {
                let diff = (frame.size.width) - newWidth
                newHeight = newHeight + CGFloat(diff) / newHeight * newHeight
                newWidth = frame.size.width
            }
        } else {
            newWidth = frame.size.width
            newHeight = (image.size.height / image.size.width) * newWidth

            if newHeight > frame.size.height {
                let diff = Float((frame.size.height) - newHeight)
                newWidth = newWidth + CGFloat(diff) / newWidth * newWidth
                newHeight = frame.size.height
            }
        }
        return .init(width: newWidth, height: newHeight)
    }
}

// MARK: - UITableViewController
extension UITableViewController {

    func makeActivityIndicator(size: CGSize) -> UIActivityIndicatorView {
        let style: UIActivityIndicatorView.Style
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                style = .medium
            } else {
                style = .medium
            }
        } else {
            style = .gray
        }

        let activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        activityIndicator.frame = .init(origin: .zero, size: size)

        return activityIndicator
    }
}

// MARK: - UIViewController + Add Child
extension UIViewController {
    
    func add(child: UIViewController, container: UIView) {
        addChild(child)
        child.view.frame = container.bounds
        container.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}


// MARK: - UIVIEWController+ADD Behaviours
protocol ViewControllerLifecycleBehavior {
    func viewDidLoad(viewController: UIViewController)
    func viewWillAppear(viewController: UIViewController)
    func viewDidAppear(viewController: UIViewController)
    func viewWillDisappear(viewController: UIViewController)
    func viewDidDisappear(viewController: UIViewController)
    func viewWillLayoutSubviews(viewController: UIViewController)
    func viewDidLayoutSubviews(viewController: UIViewController)
}
// Default implementations
extension ViewControllerLifecycleBehavior {
    func viewDidLoad(viewController: UIViewController) {}
    func viewWillAppear(viewController: UIViewController) {}
    func viewDidAppear(viewController: UIViewController) {}
    func viewWillDisappear(viewController: UIViewController) {}
    func viewDidDisappear(viewController: UIViewController) {}
    func viewWillLayoutSubviews(viewController: UIViewController) {}
    func viewDidLayoutSubviews(viewController: UIViewController) {}
}

extension UIViewController {
    func addBehaviors(_ behaviors: [ViewControllerLifecycleBehavior]) {
        let behaviorViewController = LifecycleBehaviorViewController(behaviors: behaviors)

        addChild(behaviorViewController)
        view.addSubview(behaviorViewController.view)
        behaviorViewController.didMove(toParent: self)
    }

    private final class LifecycleBehaviorViewController: UIViewController, UIGestureRecognizerDelegate {
        private let behaviors: [ViewControllerLifecycleBehavior]

        // MARK: - Lifecycle

        init(behaviors: [ViewControllerLifecycleBehavior]) {
            self.behaviors = behaviors

            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLoad() {
            super.viewDidLoad()

            view.isHidden = true

            applyBehaviors { behavior, viewController in
                behavior.viewDidLoad(viewController: viewController)
            }
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            applyBehaviors { behavior, viewController in
                behavior.viewWillAppear(viewController: viewController)
            }
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

            applyBehaviors { behavior, viewController in
                behavior.viewDidAppear(viewController: viewController)
            }
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            applyBehaviors { behavior, viewController in
                behavior.viewWillDisappear(viewController: viewController)
            }
        }

        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)

            applyBehaviors { behavior, viewController in
                behavior.viewDidDisappear(viewController: viewController)
            }
        }

        override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()

            applyBehaviors { behavior, viewController in
                behavior.viewWillLayoutSubviews(viewController: viewController)
            }
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()

            applyBehaviors { behavior, viewController in
                behavior.viewDidLayoutSubviews(viewController: viewController)
            }
        }

        // MARK: - Private

        private func applyBehaviors(body: (_ behavior: ViewControllerLifecycleBehavior, _ viewController: UIViewController) -> Void) {
            guard let parent = parent else { return }

            for behavior in behaviors {
                body(behavior, parent)
            }
        }
    }
}
