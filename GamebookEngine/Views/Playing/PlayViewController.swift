//
//  PlayViewController.swift
//  BRGamebookEngine
//
//  Created by Brad Root on 8/20/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class PlayViewController: UIViewController {
    private var player: GamePlayer

    private var decisionsAreHidden: Bool = false
    private var contentBottomConstraint: NSLayoutConstraint?

    private var pageLayout: PageLayout = .singleColumn
    private let decisionsScrollView = UIScrollView()
    private let columnDividerGuide = UILayoutGuide()
    private var columnDividerLeftConstraint: NSLayoutConstraint?
    private var columnDividerWidthConstraint: NSLayoutConstraint?
    private var decisionsColumnConstraints: [NSLayoutConstraint] = []
    private var singleColumnConstraints: [NSLayoutConstraint] = []
    private var twoColumnConstraints: [NSLayoutConstraint] = []
    private var marginConstraints: [NSLayoutConstraint] = []

    @IBOutlet var textView: UITextView!
    @IBOutlet var decisionsTableView: UITableView!
    @IBOutlet var decisionsContainerView: ContainerView!
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var decisionsLabel: UILabel!
    @IBOutlet var mainScrollViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var textViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var textViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var textViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var decisionsContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var decisionsContainerTrailingConstraint: NSLayoutConstraint!

    // MARK: Initialization

    init(for game: Game) {
        player = GamePlayer(for: game)
        super.init(nibName: nil, bundle: nil)
        player.delegate = self
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup table view
        decisionsTableView.delegate = self
        decisionsTableView.dataSource = self
        decisionsTableView.register(UINib(nibName: "PlayDecisionTableViewCell", bundle: nil), forCellReuseIdentifier: "decisionCell")

        // Setup link colors in textview
        var linkColor: UIColor = .darkGray
        var underlineColor: UIColor = .lightGray
        if #available(iOS 13.0, *) {
            linkColor = .secondaryLabel
            underlineColor = .quaternaryLabel
        }
        let linkAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: linkColor,
            NSAttributedString.Key.underlineColor: underlineColor,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
        ]
        textView.linkTextAttributes = linkAttributes

        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0

        configureBarItems()
        setupPageLayouts()

        if #available(iOS 27.1, *) {
            view.addInteraction(UIHingeInteraction { [weak self] _, _ in
                self?.view.setNeedsLayout()
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hidePage()
        loadGame()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        applyPageLayout(preferredPageLayout)
        updateColumnDivider()
        updateMargins()
    }

    private func configureBarItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Exit Game", image: UIImage(systemName: "xmark"),
            primaryAction: UIAction { [weak self] _ in self?.exitGame() }
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Restart Game", image: UIImage(systemName: "arrow.counterclockwise"),
            primaryAction: UIAction { [weak self] _ in self?.restartGame() }
        )
    }
}

// MARK: - Activities

extension PlayViewController: GamePlayerDelegate {
    fileprivate func loadGame() {
        player.loadGame()
    }

    func loadPage() {
        UIView.animate(withDuration: 0.3, animations: {
            self.hidePage()
        }, completion: { _ in
            self.showPage()
        })
    }

    @objc fileprivate func restartGame() {
        let alert = UIAlertController.createCancelableAlert(
            title: "Restart Game?",
            message: "Are you sure you want to restart this game? All progress will be reset and you'll begin at the first page.",
            primaryActionTitle: "Restart"
        ) { _ in
            self.player.restartGame()
        }
        present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor(named: "text") ?? .darkGray
    }

    @objc fileprivate func exitGame() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: UI Actions

private extension PlayViewController {
    func hidePage() {
        var textAreaFrame = textView.frame
        textAreaFrame.origin.x -= textAreaFrame.size.width / 2
        textView.frame = textAreaFrame
        textView.alpha = 0
        decisionsLabel.alpha = 0
        decisionsContainerView.alpha = 0
    }

    func showPage() {
        textView.attributedText = player.getPageAttributedString()
        decisionsTableView.reloadData()

        if player.decisions.isEmpty {
            hideDecisionsView()
        } else {
            showDecisionsView()
        }

        scrollToTop(mainScrollView)
        scrollToTop(decisionsScrollView)

        var containerFrame = textView.frame
        containerFrame.origin.x += containerFrame.size.width / 2
        textView.frame = containerFrame
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(withDuration: 0.3, animations: {
                if !self.decisionsAreHidden {
                    self.decisionsLabel.alpha = 1
                    self.decisionsContainerView.alpha = 1
                }
                self.textView.alpha = 1
            })
        }
    }

    func scrollToTop(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.adjustedContentInset.top), animated: false)
    }

    func hideDecisionsView() {
        decisionsAreHidden = true
        updateContentBottomConstraint()
    }

    func showDecisionsView() {
        decisionsAreHidden = false
        updateContentBottomConstraint()
    }

    func updateContentBottomConstraint() {
        let lastView: UIView = pageLayout == .singleColumn && !decisionsAreHidden ? decisionsContainerView : textView
        contentBottomConstraint?.isActive = false
        contentBottomConstraint = mainScrollView.bottomAnchor.constraint(equalTo: lastView.bottomAnchor, constant: standardMargin)
        contentBottomConstraint?.isActive = true
    }
}

// MARK: Page Layout

private enum PageLayout {
    case singleColumn
    case twoColumn
}

private extension PlayViewController {
    var decisionsColumnViews: [UIView] {
        [decisionsLabel, decisionsContainerView]
    }

    var standardMargin: CGFloat {
        let systemMargin = max(systemMinimumLayoutMargins.leading, systemMinimumLayoutMargins.trailing)
        return systemMargin > 0 ? systemMargin : 20
    }

    var preferredPageLayout: PageLayout {
        guard #available(iOS 27.1, *), traitCollection.horizontalSizeClass == .regular else { return .singleColumn }
        if verticalFold != nil || traitCollection.verticalBarEdge != .unspecified {
            return .twoColumn
        }
        return .singleColumn
    }

    @available(iOS 27.1, *)
    var verticalFold: UIView.ReservedRegion? {
        view.reservedRegions(kind: .division).first { $0.frame.height > $0.frame.width }
    }

    func setupPageLayouts() {
        decisionsScrollView.translatesAutoresizingMaskIntoConstraints = false
        decisionsScrollView.showsHorizontalScrollIndicator = false
        decisionsScrollView.tintColor = mainScrollView.tintColor
        decisionsScrollView.isHidden = true
        view.addSubview(decisionsScrollView)
        view.addLayoutGuide(columnDividerGuide)

        let dividerLeftConstraint = columnDividerGuide.leftAnchor.constraint(equalTo: view.leftAnchor)
        let dividerWidthConstraint = columnDividerGuide.widthAnchor.constraint(equalToConstant: 0)
        columnDividerLeftConstraint = dividerLeftConstraint
        columnDividerWidthConstraint = dividerWidthConstraint
        NSLayoutConstraint.activate([
            dividerLeftConstraint,
            dividerWidthConstraint,
            columnDividerGuide.topAnchor.constraint(equalTo: view.topAnchor),
            columnDividerGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            decisionsScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            decisionsScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            decisionsScrollView.leadingAnchor.constraint(equalTo: columnDividerGuide.trailingAnchor),
            decisionsScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mainScrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.widthAnchor),
        ])

        let columnViews = decisionsColumnViews
        let isColumnView: (AnyObject?) -> Bool = { item in columnViews.contains { $0 === item } }
        let columnConstraints = mainScrollView.constraints.filter { isColumnView($0.firstItem) || isColumnView($0.secondItem) }
        decisionsColumnConstraints = columnConstraints.filter { isColumnView($0.firstItem) && isColumnView($0.secondItem) }
        singleColumnConstraints = columnConstraints.filter { !decisionsColumnConstraints.contains($0) } + [
            mainScrollViewTrailingConstraint,
            textViewLeadingConstraint,
            textViewTrailingConstraint,
        ]

        let decisionsFrame = decisionsScrollView.frameLayoutGuide
        let decisionsContent = decisionsScrollView.contentLayoutGuide
        let decisionsContainerWidthConstraint = decisionsContainerView.widthAnchor.constraint(
            greaterThanOrEqualTo: decisionsFrame.widthAnchor
        )
        decisionsContainerWidthConstraint.priority = .defaultHigh
        let twoColumnMarginConstraints = [
            textView.leadingAnchor.constraint(greaterThanOrEqualTo: mainScrollView.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(greaterThanOrEqualTo: textView.trailingAnchor),
            decisionsLabel.topAnchor.constraint(equalTo: decisionsContent.topAnchor),
            decisionsContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: decisionsFrame.leadingAnchor),
            decisionsFrame.trailingAnchor.constraint(greaterThanOrEqualTo: decisionsContainerView.trailingAnchor),
            decisionsContent.bottomAnchor.constraint(equalTo: decisionsContainerView.bottomAnchor),
        ]
        twoColumnConstraints = twoColumnMarginConstraints + [
            mainScrollView.trailingAnchor.constraint(equalTo: columnDividerGuide.leadingAnchor),
            decisionsContent.widthAnchor.constraint(equalTo: decisionsFrame.widthAnchor),
            decisionsContainerView.centerXAnchor.constraint(equalTo: decisionsFrame.centerXAnchor),
            decisionsContainerWidthConstraint,
        ]
        marginConstraints = twoColumnMarginConstraints + [
            textViewTopConstraint,
            textViewLeadingConstraint,
            textViewTrailingConstraint,
            decisionsContainerLeadingConstraint,
            decisionsContainerTrailingConstraint,
        ]
        updateContentBottomConstraint()
    }

    func updateMargins() {
        let margin = standardMargin
        for constraint in marginConstraints + [contentBottomConstraint].compactMap({ $0 }) where constraint.constant != margin {
            constraint.constant = margin
        }
    }

    func applyPageLayout(_ layout: PageLayout) {
        guard layout != pageLayout else { return }
        pageLayout = layout

        switch layout {
        case .singleColumn:
            NSLayoutConstraint.deactivate(twoColumnConstraints)
            decisionsColumnViews.forEach { mainScrollView.addSubview($0) }
            NSLayoutConstraint.activate(decisionsColumnConstraints + singleColumnConstraints)
            decisionsScrollView.isHidden = true
        case .twoColumn:
            NSLayoutConstraint.deactivate(singleColumnConstraints)
            decisionsColumnViews.forEach { decisionsScrollView.addSubview($0) }
            NSLayoutConstraint.activate(decisionsColumnConstraints + twoColumnConstraints)
            decisionsScrollView.isHidden = false
        }
        updateContentBottomConstraint()
    }

    func updateColumnDivider() {
        let textColumnFraction: CGFloat = 0.6
        let safeFrame = view.bounds.inset(by: view.safeAreaInsets)
        let textColumnWidth = safeFrame.width * textColumnFraction
        let dividerX = view.effectiveUserInterfaceLayoutDirection == .rightToLeft
            ? safeFrame.maxX - textColumnWidth
            : safeFrame.minX + textColumnWidth
        var dividerFrame = CGRect(x: dividerX, y: 0, width: 0, height: 0)
        if #available(iOS 27.1, *), let fold = verticalFold {
            dividerFrame = fold.frame
        }

        if columnDividerLeftConstraint?.constant != dividerFrame.minX {
            columnDividerLeftConstraint?.constant = dividerFrame.minX
        }
        if columnDividerWidthConstraint?.constant != dividerFrame.width {
            columnDividerWidthConstraint?.constant = dividerFrame.width
        }
    }
}

// MARK: Decisions Table View Delegate

extension PlayViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return player.decisions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "decisionCell",
            for: indexPath
        ) as? PlayDecisionTableViewCell else { fatalError() }

        cell.decisionTextLabel?.text = player.decisions[indexPath.row].content
        switch player.getFont() {
        case .serif:
            cell.decisionTextLabel?.font = UIFont(name: "Georgia", size: cell.decisionTextLabel?.font.pointSize ?? 16)
        default:
            cell.decisionTextLabel?.font = cell.decisionTextLabel?.font
        }

        cell.separatorView.isHidden = false
        if indexPath.row == player.decisions.count - 1 {
            cell.separatorView.isHidden = true
        }

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        player.pickedDecision(at: indexPath.row)
    }
}
