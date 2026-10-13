/// Joins indices into groups, pair by pair.
nonisolated struct UnionFind {
    private var parents: [Int]

    init(count: Int) {
        parents = Array(0..<count)
    }

    mutating func root(of index: Int) -> Int {
        var current = index
        while parents[current] != current {
            parents[current] = parents[parents[current]]
            current = parents[current]
        }
        return current
    }

    mutating func join(_ first: Int, _ second: Int) {
        let firstRoot = root(of: first)
        let secondRoot = root(of: second)
        if firstRoot != secondRoot {
            parents[max(firstRoot, secondRoot)] = min(firstRoot, secondRoot)
        }
    }

    /// The groups of two or more indices, each sorted, in the order of their smallest index.
    mutating func groups() -> [[Int]] {
        var byRoot: [Int: [Int]] = [:]
        for index in parents.indices {
            byRoot[root(of: index), default: []].append(index)
        }
        return byRoot.values.filter { $0.count > 1 }.sorted { $0[0] < $1[0] }
    }
}
