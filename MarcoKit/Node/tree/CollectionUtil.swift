import Foundation

internal extension MarcoCollectionNode {
    func collectionRemove(rawIndex: Int) -> Range<Int> {
        let range: Range<Int>

        let itemCount = children.reduce(0) { (count, node) in count + (isItem(node) ? 1 : 0) }

        if (itemCount == 1) {
            let startIndex = hasEnclosingElements ? 1 : 0
            let endIndex = children.count - 1 - (hasEnclosingElements ? 1 : 0)
            range = startIndex..<(endIndex + 1)
        } else if ((children.first { isItem($0) }) === children[rawIndex]) {
            let startIndex = rawIndex
            var endIndex = startIndex + 1
            while (endIndex < children.count - 1) {
                guard children[endIndex] is MarcoWhitespaceNode else { break }
                endIndex += 1
            }

            range = startIndex..<endIndex
        } else {
            let endIndex = rawIndex
            var startIndex = endIndex - 1
            while (startIndex > 0) {
                guard children[startIndex] is MarcoWhitespaceNode else { break }
                startIndex -= 1
            }

            range = (startIndex + 1)..<(endIndex + 1)
        }

        range.forEach { children[$0].parent = nil }
        children.removeSubrange(range)

        return range
    }

    func collectionInsert(index: Int, node valueNode: MarcoNode) -> (delta: Int, pos: Int) {
        func insertNodes(_ nodes: MarcoNode..., at index: Int) {
            nodes.forEach { $0.parent = self }
            children.insert(contentsOf: nodes, at: index)
        }

        func getRawIndex(index: Int, includeIgnored: Bool) -> Int {
            var isIgnored = false
            var current = 0

            for (rawIndex, child) in children.enumerated() {
                if !isIgnored, isItem(child) {
                    if (current == index) {
                        return rawIndex
                    }
                    current += 1
                }

                isIgnored = !includeIgnored && child.isIgnoring
            }

            preconditionFailure("Child with index \(index) not found")
        }

        let itemCount = children.reduce(0) { (count, node) in count + (isItem(node) ? 1 : 0) }

        if (itemCount == 0) {
            var newChildren: [MarcoNode]

            if !isComplexNode(valueNode) {
                newChildren = [WS(" "), valueNode, WS(" ")]
            } else {
                let indentInParent = self.indentInParent()
                let indent = indentInParent + SINGLE_INDENT
                valueNode.applyIndent(indent: indent)

                newChildren = [WSnl("\n" + indent), valueNode, WSnl("\n" + indentInParent)]
            }

            if hasEnclosingElements {
                newChildren.insert(children.first!, at: 0)
                newChildren.append(children.last!)
            }

            newChildren.forEach { $0.parent = self }
            let oldChildren = self.children
            self.children = newChildren
            oldChildren.forEach { $0.parent = nil }
            
            return (0, hasEnclosingElements ? 2 : 1)
        }

        let selfContainsNewLine = children.first { ($0 as? MarcoWhitespaceNode)?.containsNewLine ?? false } != nil
        if (!selfContainsNewLine && isComplexNode(valueNode)) {
            prettifySelf()
        }

        if (index == 0) {
            let whitespace = whitespaceBeforeChild(index: getRawIndex(index: 0, includeIgnored: true))

            if (whitespace.contains("\n")) {
                let indent = whitespace.textAfterNewLine()
                valueNode.applyIndent(indent: indent + SINGLE_INDENT)

                if let existingWhitespace = children[1] as? MarcoWhitespaceNode, existingWhitespace.containsNewLine {
                    insertNodes(WSnl("\n" + indent), valueNode, at: 1)
                    return (2, 2)
                } else {
                    insertNodes(WSnl("\n" + indent), valueNode, WSnl("\n" + indent), at: 1)
                    return (3, 2)
                }
            } else {
                insertNodes(valueNode, WS(" "), at: 1)
                return (2, 1)
            }
        }

        let rawIndexBeforeElement: Int
        if (index == Int.max) {
            rawIndexBeforeElement = (children.lastIndex { isItem($0) })!
        } else {
            rawIndexBeforeElement = getRawIndex(index: index - 1, includeIgnored: false)
        }

        let rawIndexToInsert = rawIndexBeforeElement + 1
        let whitespace = whitespaceBeforeChild(index: rawIndexBeforeElement)

        if (whitespace.contains("\n") || itemCount == 1) {
            let indent = whitespace.textAfterNewLine()
            valueNode.applyIndent(indent: indent)
            insertNodes(WSnl("\n" + indent), valueNode, at: rawIndexToInsert)
        } else {
            insertNodes(WS(" "), valueNode, at: rawIndexToInsert)
        }

        return (2, rawIndexToInsert + 1)
    }

    private func prettifySelf() {
        let indentInParent = self.indentInParent()
        let visitor = MutatingPrettifyingVisitor(forceNewLine: true, isRecursive: false, reorderKeys: false)
        _ = self.accept(visitor, data: 0)
        self.applyIndent(indent: indentInParent)
    }

    private func isItem(_ node: MarcoNode) -> Bool {
        return node is MarcoValueNode || node is MarcoKeyValuePairNode
    }

    private func isComplexNode(_ node: MarcoNode) -> Bool {
        return node is MarcoCollectionNode
            || node is MarcoStringLiteralNode
            || node is MarcoKeyValuePairNode
    }
}
