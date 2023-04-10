//
//  PagesScene.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 9/3/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import SpriteKit

class PageNode: SKSpriteNode {
    var page: Page?
}

class PagesScene: SKScene, PagesTableViewDelegate {
    var relationships: [(origin: Page, destination: Page)] = []
    var nodes: [Page: SKSpriteNode] = [:]
    var groupNodes: [SKSpriteNode: SKSpriteNode] = [:]
    var rowNodes: [SKSpriteNode: SKSpriteNode] = [:]
    var allPages: [Page] = []

    var lastSelectedPage: Page?

    var previousCameraPoint = CGPoint.zero
    var previousCameraScale = CGFloat()
    var currentCameraScale: CGFloat = 4
    private var cameraNode: SKCameraNode = .init()

    var nodeSize: CGFloat = 440
    var nodeSpacing: CGFloat = 100
    var groupSpacing: CGFloat = 400

    var pageTexture = SKTexture(imageNamed: "page-sprite")
    let selectionTexture = SKTexture(imageNamed: "selection")
    var selectionNode = SKSpriteNode()
    var lineColor = SKColor.black
    var reverseLineColor = SKColor.darkGray

    weak var pageDelegate: PagesTableViewDelegate?

    var game: Game? {
        didSet {
            if let game = game {
                GameDatabase.standard.fetchFirstPage(for: game) { page in
                    guard let page = page else { return }
                    self.firstPage = page
                }
            }
        }
    }

    var firstPage: Page? {
        didSet {
            guard let page = firstPage else { return }
            drawPages(page)
        }
    }

    // MARK: - Drawing

    func redrawPages() {
        Log.info("Trying to redraw all pages...")
        guard let page = firstPage else { return }
        removeAllChildren()
        relationships.removeAll()
        nodes.removeAll()
        groupNodes.removeAll()
        rowNodes.removeAll()
        allPages.removeAll()
        drawPages(page)
        moveCameraToSelectedPage()
    }

    fileprivate func drawPages(_ firstPage: Page) {
        var rows: [Int: [Int: [Page]]] = [:]
        rows[0] = [0: [firstPage]]
        allPages.append(firstPage)
        rows = populateRows(rows: rows, rowLevel: 1, groupLevel: 0, destinations: [firstPage])

        let rowCount = rows.count
        var rowValue = 0
        var yLevel: CGFloat = frame.height
        let xLevel = frame.midX

        // MARK: Draw Rows

        while rowValue < rowCount {
            let row = rows[rowValue]!
            var groupNodes: [SKSpriteNode] = []
            var groupKeys = Array(row.keys)
            groupKeys = groupKeys.sorted()
            for key in groupKeys {
                if let group = row[key] {
                    let groupNode = createNodeGroup(group)
                    groupNodes.append(groupNode)
                }
            }

            let rowWidth: CGFloat = {
                var width: CGFloat = 0
                for group in groupNodes {
                    width += group.frame.width
                }
                if groupNodes.count > 1 {
                    width += CGFloat(CGFloat(groupNodes.count - 1) * groupSpacing)
                }
                return width
            }()

            let rowNode = SKSpriteNode(color: UIColor.clear, size: CGSize(width: rowWidth, height: nodeSize))
            rowNode.anchorPoint = CGPoint(x: 0, y: 0)
            var xPosition: CGFloat = 0
            for groupNode in groupNodes {
                rowNode.addChild(groupNode)
                rowNodes[groupNode] = rowNode
                groupNode.position = CGPoint(x: xPosition, y: 0)
                xPosition += groupNode.size.width
                if !rowNode.children.isEmpty {
                    xPosition += groupSpacing
                }
            }

            addChild(rowNode)
            rowNode.position = CGPoint(x: xLevel - (rowWidth / 2), y: yLevel)

            rowValue += 1
            yLevel -= nodeSize + groupSpacing
        }

        // MARK: Draw Lines

        for relationship in relationships {
            guard let originNode = nodes[relationship.origin],
                  let destinationNode = nodes[relationship.destination]
            else {
                Log.error("Relationship match not found: \(relationship.origin) \(relationship.destination)")
                continue
            }
            let originPosition = originNode.convert(CGPoint(x: nodeSize / 2, y: nodeSize * 0.10), to: self)
            let destinationPosition = destinationNode.convert(CGPoint(x: nodeSize / 2, y: nodeSize * 0.90), to: self)
            let yourline = SKShapeNode()
            let pathToDraw = CGMutablePath()
            pathToDraw.move(to: originPosition)
            pathToDraw.addLine(to: destinationPosition)
            let angle = abs(round(angleBetween(pointOne: originPosition, andPointTwo: destinationPosition) * 100) / 100)
            yourline.path = pathToDraw
            if angle >= 1.57 {
                yourline.strokeColor = lineColor
                yourline.zPosition = -1
            } else {
                yourline.strokeColor = reverseLineColor
                yourline.zPosition = -2
            }
            yourline.lineWidth = 20

            addChild(yourline)
            let labelNode = SKLabelNode(text: "\(angle)")
            labelNode.fontSize = 10
            addChild(labelNode)
            labelNode.color = .white
            labelNode.position = originPosition
        }

        // MARK: Create Selection Node

        selectionNode = SKSpriteNode(texture: selectionTexture, size: CGSize(width: 563, height: 170))

        highlightPageNode()
    }

    // MARK: Draw Row Pages

    func createNodeGroup(_ group: [Page]) -> SKSpriteNode {
        let groupCount = CGFloat(group.count)
        let groupWidth = CGFloat((groupCount * nodeSize) + ((groupCount - 1) * nodeSpacing))
        let groupNode = SKSpriteNode(color: SKColor.clear, size: CGSize(width: groupWidth, height: nodeSize))
        groupNode.anchorPoint = CGPoint(x: 0, y: 0)
        var innerXLevel: CGFloat = 0
        for page in group {
            let node = PageNode(texture: pageTexture, size: CGSize(width: nodeSize, height: nodeSize))
            node.page = page
            node.anchorPoint = CGPoint(x: 0, y: 0)
            node.name = "page"
            groupNodes[node] = groupNode
            groupNode.addChild(node)
            node.zPosition = 1
            node.position = CGPoint(x: innerXLevel, y: 0)

            let pageContent = SKLabelNode(text: page.content.replacingOccurrences(of: "\n\n", with: " ").trunc(length: 480, trailing: "..."))
            pageContent.fontName = "HelveticaNeue"
            pageContent.fontColor = UIColor(named: "text") ?? .darkText
            pageContent.numberOfLines = 0
            pageContent.fontSize = 20
            pageContent.zPosition = 2
            pageContent.preferredMaxLayoutWidth = nodeSize - 100

            node.addChild(pageContent)
            pageContent.position = CGPoint(x: (nodeSize / 2) - 10, y: nodeSize - pageContent.frame.height - 40)

            // Warning?
            if page.hasIssues {
                let warningSymbol = SKSpriteNode(imageNamed: "large-warning")
                warningSymbol.color = .red
                warningSymbol.colorBlendFactor = 1
                warningSymbol.alpha = 0.3
                warningSymbol.size = CGSize(width: nodeSize - 100, height: nodeSize - 100)
                warningSymbol.zPosition = 1.5
                node.addChild(warningSymbol)
                warningSymbol.position = CGPoint(x: nodeSize / 2, y: nodeSize / 2)
            }

            nodes[page] = node

            innerXLevel += nodeSize + nodeSpacing
        }
        return groupNode
    }

    func populateRows(rows: [Int: [Int: [Page]]], rowLevel: Int, groupLevel: Int, destinations: [Page]) -> [Int: [Int: [Page]]] {
        var mutableRows = rows
        var mutableGroupLevel = groupLevel
        if mutableRows[rowLevel] == nil {
            mutableRows[rowLevel] = [:]
        }
        for page in destinations {
            let newDestinations = getDestinations(page)
            if !newDestinations.isEmpty {
                var destinations: [Page] = []
                for destination in newDestinations {
                    relationships.append((origin: page, destination: destination))
                    if !allPages.contains(destination) {
                        destinations.append(destination)
                    }
                }
                if !destinations.isEmpty {
                    if let mRows = mutableRows[rowLevel]?[mutableGroupLevel], !mRows.isEmpty {
                        mutableGroupLevel += 1
                    }
                    mutableRows[rowLevel]![mutableGroupLevel] = destinations

                    allPages.append(contentsOf: destinations)
                    mutableRows = populateRows(
                        rows: mutableRows,
                        rowLevel: rowLevel + 1,
                        groupLevel: mutableGroupLevel,
                        destinations: destinations
                    )
                }
                mutableGroupLevel += 1
            }
        }
        return mutableRows
    }

    func getDestinations(_ page: Page) -> [Page] {
        var destinations: [Page] = []
        if let decisions = page.decisions?.array as? [Decision] {
            for decision in decisions {
                if let page = decision.destination {
                    destinations.append(page)
                }
            }
        }
        return destinations
    }

    // MARK: - Scene

    override func sceneDidLoad() {
        camera = cameraNode
        setBackgroundColor()
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 4)
        addChild(cameraNode)
        cameraNode.setScale(currentCameraScale)
        camera = cameraNode
    }

    func setBackgroundColor() {
        if #available(iOS 13.0, *) {
            backgroundColor = UIColor(named: "background") ?? UIColor(white: 0.9, alpha: 1)
        } else {
            backgroundColor = UIColor(white: 0.9, alpha: 1)
        }
    }

    func changeToDarkMode() {
        setBackgroundColor()
        pageTexture = SKTexture(imageNamed: "page-sprite-dark")
        lineColor = SKColor.white
        reverseLineColor = SKColor.darkGray
        redrawPages()
    }

    func changeToLightMode() {
        setBackgroundColor()
        pageTexture = SKTexture(imageNamed: "page-sprite")
        lineColor = SKColor.black
        reverseLineColor = SKColor.lightGray
        redrawPages()
    }

    override func didMove(to view: SKView) {
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGesture)

        let pinchGesture = UIPinchGestureRecognizer()
        pinchGesture.addTarget(self, action: #selector(pinchGestureAction(_:)))
        view.addGestureRecognizer(pinchGesture)

        let tapRec = UITapGestureRecognizer()
        tapRec.addTarget(self, action: #selector(tapGestureAction(_:)))
        tapRec.numberOfTouchesRequired = 1
        tapRec.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRec)
    }

    @objc func tapGestureAction(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            var post = sender.location(in: sender.view)
            post = convertPoint(fromView: post)
            let touchNodes = nodes(at: post)

            for node in touchNodes where node.name == "page" {
                guard let node = node as? PageNode, let page = node.page else { return }
                pageDelegate?.selectedPage(page)
                self.selectedPage(page)
            }
        }
    }

    func selectedPage(_ page: Page) {
        // Highlight page
        lastSelectedPage = page
        Log.debug("Selected page on game overview...")
        highlightPageNode()
        moveCameraToSelectedPage()
    }

    func moveCameraToSelectedPage() {
        guard let page = lastSelectedPage, let node = nodes[page] else { return }
        let currentNodePositionInScene = convert(node.position, from: node.parent!)
        let translatedNodePosition = CGPoint(
            x: currentNodePositionInScene.x + (size.width / 2),
            y: currentNodePositionInScene.y - (size.height - nodeSize / 2)
        )
        camera?.position = translatedNodePosition
    }

    func deletedPage(_: Page) {
        redrawPages()
    }

    func highlightPageNode() {
        selectionNode.removeFromParent()
        guard let lastSelectedPage = lastSelectedPage, let node = nodes[lastSelectedPage] else { return }
        selectionNode.alpha = 1
        node.addChild(selectionNode)
        selectionNode.zPosition = -1
        selectionNode.position = CGPoint(x: node.size.width / 2, y: 40)
    }

    @objc func pinchGestureAction(_ sender: UIPinchGestureRecognizer) {
        guard let camera = camera else {
            return
        }
        if sender.state == .began {
            previousCameraScale = camera.xScale
        }
        let scale = previousCameraScale * 1 / sender.scale
        if scale > 1, scale < 20 {
            currentCameraScale = scale
            camera.setScale(scale)
        }
    }

    @objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
        // The camera has a weak reference, so test it
        guard let camera = camera else {
            return
        }
        // If the movement just began, save the first camera position
        if sender.state == .began {
            previousCameraPoint = camera.position
        }
        // Perform the translation
        let translation = sender.translation(in: view)
        let newPosition = CGPoint(
            x: previousCameraPoint.x + translation.x * -1 * currentCameraScale,
            y: previousCameraPoint.y + translation.y * currentCameraScale
        )
        camera.position = newPosition
    }

    override func update(_: TimeInterval) {
//        print("updating...")
    }
}
