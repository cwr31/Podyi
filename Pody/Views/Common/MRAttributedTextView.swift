import Foundation
import SwiftUI

public struct MRAttributedTextView: UIViewRepresentable {
    var text: String
    var subsString: [String]
    var width: GeometryProxy
    var textFont: UIFont
    var subsStringFont: UIFont
    var subsStringColor: UIColor
    var alignment: NSTextAlignment
    var paddingHorizontal: CGFloat
    var onTapItemString: (String) -> Void

    /// Description
    /// - Parameters:
    ///   - text: The String with subsString
    ///   - subStrings: The SubsString Array
    ///   - width: The Width of view
    ///   - textFont: The font of text (Default systemFont)
    ///   - subsStringFont: The font of subsString (Default systemFont)
    ///   - subsStringColor:The color of subsString (Default systemBlue)
    ///   - alignment: Alignment of view (Default Center)
    ///   - paddingHorizontal: The padding of view (Default 0)
    ///   - onTapItemString: The action of subsStrings
    public init(text: String,
                subStrings: [String],
                width: GeometryProxy,
                textFont: UIFont = .systemFont(ofSize: 16),
                subsStringFont: UIFont = .systemFont(ofSize: 16),
                subsStringColor: UIColor = UIColor.systemBlue,
                alignment: NSTextAlignment = .center,
                paddingHorizontal: CGFloat = 0,
                onTapItemString: @escaping ((String) -> Void))
    {
        self.text = text
        subsString = subStrings
        self.width = width
        self.textFont = textFont
        self.subsStringFont = subsStringFont
        self.subsStringColor = subsStringColor
        self.alignment = alignment
        self.paddingHorizontal = paddingHorizontal
        self.onTapItemString = onTapItemString
    }

    public class Coordinator: NSObject {
        var parent: MRAttributedTextView
        init(parent: MRAttributedTextView) {
            self.parent = parent
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public func makeUIView(context _: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = alignment
        label.font = textFont
        label.preferredMaxLayoutWidth = (width.maxWidth - paddingHorizontal)
        return label
    }

    func createAttrString() -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        subsString.forEach { string in
            let range = (text as NSString).range(of: string)
            let attrs = [NSMutableAttributedString.Key.foregroundColor: subsStringColor,
                         NSAttributedString.Key.font: subsStringFont]
            let subString = NSMutableAttributedString(string: string, attributes: attrs)
            attributedString.replaceCharacters(in: range, with: subString)
        }
        return attributedString
    }

    public func updateUIView(_ label: UILabel, context _: Context) {
        label.attributedText = createAttrString()
        label.addTapGestureRecognizer { sender in
            subsString.forEach { string in
                let range = (text as NSString).range(of: string)
                if sender.didTapAttributedTextInLabel(label: label, inRange: range) {
                    onTapItemString(string)
                }
            }
        }
    }
}

extension GeometryProxy {
    var maxWidth: CGFloat {
        size.width - safeAreaInsets.leading - safeAreaInsets.trailing
    }
}

import UIKit

extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        let locationOfTouchInLabel = location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}

extension UIView {
    fileprivate enum AssociatedObjectKeys {
        static var tapGestureRecognizer = "LabelClickEventObjectKey"
    }

    fileprivate typealias Action = ((UITapGestureRecognizer) -> Void)?

    private var tapGestureRecognizerAction: Action? {
        set {
            if let newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }

    public func addTapGestureRecognizer(action: ((UITapGestureRecognizer) -> Void)?) {
        isUserInteractionEnabled = true
        tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(sender:)))
        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = tapGestureRecognizerAction {
            action?(sender)
        } else {
            print("no action")
        }
    }
}

extension String {
    mutating func replace(_ originalString: String, with newString: String) {
        self = replacingOccurrences(of: originalString, with: newString)
    }
}
