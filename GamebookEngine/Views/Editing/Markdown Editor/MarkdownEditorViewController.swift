//
//  MarkdownEditorViewController.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 8/27/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class MarkdownEditorViewController: UIViewController {
    var page: Page
    @IBOutlet var textView: UITextView!
    @IBOutlet var textAreaBottomConstraint: NSLayoutConstraint!

    // MARK: Initialization

    init(with page: Page) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(insertBold) || action == #selector(insertItalic) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }

    // MARK: View Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Markdown Editor"

        setupKeyboard()
    }

    // MARK: View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadContent()
    }

    override func viewWillDisappear(_: Bool) {
        saveContent()
        super.viewWillDisappear(true)
    }

    // MARK: Save & Load

    func loadContent() {
        textView.text = page.content
    }

    func saveContent() {
        Log.info("Saving page content...")
        page.setContent(to: textView.text)
    }
}

// MARK: Editor Keyboard

extension MarkdownEditorViewController: UITextViewDelegate {
    fileprivate func setupKeyboard() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        toolbar.sizeToFit()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: .init(systemName: "checkmark"), style: .done, target: self, action: #selector(doneAction)),
        ]
        textView.inputAccessoryView = toolbar
        textView.delegate = self

        if #unavailable(iOS 16) {
            UIMenuController.shared.menuItems = [
                UIMenuItem(title: "Bold", action: #selector(insertBold)),
                UIMenuItem(title: "Italic", action: #selector(insertItalic)),
            ]
        }

        textView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        let newPosition = textView.endOfDocument
        textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        textView.becomeFirstResponder()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func insertBold() {
        guard let selectedRange = textView.selectedTextRange, let text = textView.text(in: selectedRange) else { return }
        textView.replace(selectedRange, withText: "**\(text)**")
        if text.isEmpty {
            textView.selectedTextRange = textView.textRange(
                from: textView.position(from: selectedRange.end, offset: 2)!,
                to: textView.position(from: selectedRange.end, offset: 2)!
            )
        }
    }

    @objc func insertItalic() {
        guard let selectedRange = textView.selectedTextRange, let text = textView.text(in: selectedRange) else { return }
        textView.replace(selectedRange, withText: "_\(text)_")
        if text.isEmpty {
            textView.selectedTextRange = textView.textRange(
                from: textView.position(from: selectedRange.end, offset: 1)!,
                to: textView.position(from: selectedRange.end, offset: 1)!
            )
        }
    }

    func textViewDidEndEditing(_: UITextView) {
        saveContent()
    }

    @available(iOS 16, *)
    func textView(_ textView: UITextView, editMenuForTextIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
        let bold = UIAction(title: "Bold", image: UIImage(systemName: "bold")) { [weak self] _ in self?.insertBold() }
        let italic = UIAction(title: "Italic", image: UIImage(systemName: "italic")) { [weak self] _ in self?.insertItalic() }
        return UIMenu(children: [bold, italic] + suggestedActions)
    }

    @objc func doneAction() {
        textView.resignFirstResponder()
        saveContent()
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height

            textAreaBottomConstraint.constant = keyboardHeight
        }
    }

    @objc func keyboardWillHide(_: Notification) {
        textAreaBottomConstraint.constant = 0
    }
}
