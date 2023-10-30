//
//  LoadMoreCell.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 30.10.2023.
//

import UIKit

final class LoadMoreCell: UITableViewCell {
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        return indicator
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            contentView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            contentView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 8)
        ])
        return label
    }()
    
    var isLoading: Bool {
        get { activityIndicator.isAnimating }
        set {
            if newValue {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    var message: String? {
        get { messageLabel.text }
        set { messageLabel.text = newValue }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}
