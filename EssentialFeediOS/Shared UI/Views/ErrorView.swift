//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 17.10.2023.
//

import UIKit

public final class ErrorView: UIButton {
    public var message: String? {
        get { return isVisible ? configuration?.title : nil }
        set { setMessageAnimated(newValue) }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        hideMessage()
        configureUI()
    }
    
    var onDismiss: (() -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private var isVisible: Bool {
        return alpha > 0
    }
    
    private var titleAttributes: AttributeContainer {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        var attributes = AttributeContainer()
        attributes.paragraphStyle = paragraphStyle
        attributes.font = UIFont.preferredFont(forTextStyle: .body)
        return attributes
    }
    
    private func configureUI() {
        backgroundColor = .systemRed
        var configuration = Configuration.plain()
        configuration.titlePadding = 0
        configuration.baseForegroundColor = .white
        configuration.background.backgroundColor = .systemRed
        configuration.background.cornerRadius = 0
        self.configuration = configuration
        
        addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
    }
    
    private func setMessageAnimated(_ message: String?) {
        if let message = message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }
    
    private func showAnimated(_ message: String) {
        configuration?.attributedTitle = AttributedString(message, attributes: titleAttributes)
        configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    private func hideMessage() {
        configuration?.attributedTitle = nil
        configuration?.contentInsets = .zero
        alpha = 0
    }
    
    @objc private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed { 
                    self.hideMessage()
                    self.onDismiss?()
                }
            }
        )
    }
}
