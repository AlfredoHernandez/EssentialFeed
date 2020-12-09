//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

public final class ErrorView: UIButton {
    var onHide: (() -> Void)?
    public var message: String? {
        get { isVisible ? title(for: .normal) : nil }
        set { setMessageAnimated(newValue) }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func configure() {
        backgroundColor = .errorBackgroundColor
        addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
        configureLabel()
        hideMessage()
    }

    func configureLabel() {
        titleLabel?.textColor = .white
        titleLabel?.textAlignment = .center
        titleLabel?.numberOfLines = 0
        titleLabel?.font = .preferredFont(forTextStyle: .body)
        titleLabel?.adjustsFontForContentSizeCategory = true
    }

    private var isVisible: Bool {
        alpha > 0
    }

    private func setMessageAnimated(_ message: String?) {
        if let message = message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }

    private func showAnimated(_ message: String) {
        setTitle(message, for: .normal)
        contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    @objc private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed { self.hideMessage() }
            }
        )
    }

    private func hideMessage() {
        setTitle(nil, for: .normal)
        alpha = 0
        contentEdgeInsets = .init(top: -2.5, left: 0, bottom: -2.5, right: 0)
        onHide?()
    }
}

extension UIColor {
    static var errorBackgroundColor: UIColor {
        UIColor(red: 1, green: 0.41568627450000001, blue: 0.41568627450000001, alpha: 1)
    }
}
