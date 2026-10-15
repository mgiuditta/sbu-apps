import Foundation

/// Every imported chat, in one SQLite file in Application Support, with a full-text index.
///
/// An actor: imports, statistics and searches run off the main thread, one at a time, on the one
/// connection. SQLite rather than SwiftData because a chat is tens of thousands of rows that are
/// only ever counted, grouped and searched.
actor ChatStore {
    private let database: SQLiteDatabase

    /// The schema version in `PRAGMA user_version`.
    private static let schemaVersion = 1

    /// Opens the store at `url`, or an empty in-memory one for previews and tests.
    init(url: URL?) throws {
        if let url {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        }
        database = try SQLiteDatabase(url: url)
        try database.execute("PRAGMA journal_mode = WAL; PRAGMA foreign_keys = ON;")
        try Self.migrate(database)
    }

    /// `Application Support/Chats/chats.sqlite`.
    static var defaultURL: URL {
        URL.applicationSupportDirectory.appending(path: "Chats/chats.sqlite")
    }

    private static func migrate(_ database: SQLiteDatabase) throws {
        let version = try database.prepare("PRAGMA user_version").map { Int($0.int(0)) }.first ?? 0
        guard version < schemaVersion else { return }
        try database.execute("""
        CREATE TABLE IF NOT EXISTS chat (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            owner_sender TEXT,
            owner_chosen INTEGER NOT NULL DEFAULT 0,
            first_at REAL NOT NULL,
            last_at REAL NOT NULL,
            source_format TEXT NOT NULL,
            has_media INTEGER NOT NULL DEFAULT 0,
            imported_at REAL NOT NULL
        );
        CREATE TABLE IF NOT EXISTS message (
            id INTEGER PRIMARY KEY,
            chat_id INTEGER NOT NULL REFERENCES chat(id) ON DELETE CASCADE,
            sent_at REAL NOT NULL,
            sender TEXT,
            text TEXT NOT NULL,
            kind TEXT NOT NULL,
            word_count INTEGER NOT NULL,
            line_hash INTEGER NOT NULL,
            UNIQUE (chat_id, line_hash)
        );
        CREATE INDEX IF NOT EXISTS message_chat_time ON message (chat_id, sent_at);
        CREATE INDEX IF NOT EXISTS message_hash ON message (line_hash);
        CREATE VIRTUAL TABLE IF NOT EXISTS message_fts USING fts5 (
            text, content = 'message', content_rowid = 'id', tokenize = 'unicode61 remove_diacritics 2'
        );
        CREATE TRIGGER IF NOT EXISTS message_fts_insert AFTER INSERT ON message WHEN new.kind = 'text' BEGIN
            INSERT INTO message_fts (rowid, text) VALUES (new.id, new.text);
        END;
        CREATE TRIGGER IF NOT EXISTS message_fts_delete AFTER DELETE ON message WHEN old.kind = 'text' BEGIN
            INSERT INTO message_fts (message_fts, rowid, text) VALUES ('delete', old.id, old.text);
        END;
        PRAGMA user_version = \(schemaVersion);
        """)
    }

    // MARK: - Chats

    /// Every chat, the most recently imported first.
    func chats() throws -> [ChatSummary] {
        try database.prepare("\(Self.summarySelect) ORDER BY c.imported_at DESC, c.id DESC").map(Self.summary)
    }

    func chat(id: Int64) throws -> ChatSummary? {
        try database.prepare("\(Self.summarySelect) WHERE c.id = ?1").bind(.integer(id)).map(Self.summary).first
    }

    private static let summarySelect = """
    SELECT c.id, c.title, c.owner_sender, c.owner_chosen, c.first_at, c.last_at, c.has_media, c.source_format,
           (SELECT COUNT(*) FROM message m WHERE m.chat_id = c.id AND m.kind != 'system')
    FROM chat c
    """

    private static func summary(_ row: SQLiteStatement) -> ChatSummary {
        ChatSummary(
            id: row.int(0),
            title: row.text(1) ?? "",
            owner: row.text(2),
            ownerChosen: row.int(3) != 0,
            firstMessageAt: Date(timeIntervalSince1970: row.double(4)),
            lastMessageAt: Date(timeIntervalSince1970: row.double(5)),
            messageCount: Int(row.int(8)),
            hasMedia: row.int(6) != 0,
            sourceFormat: row.text(7) ?? ""
        )
    }

    /// Everyone who wrote in the chat, most messages first.
    func senders(chatID: Int64) throws -> [String] {
        try database.prepare("""
        SELECT sender FROM message WHERE chat_id = ?1 AND kind != 'system' AND sender IS NOT NULL
        GROUP BY sender ORDER BY COUNT(*) DESC, sender
        """).bind(.integer(chatID)).map { $0.text(0) ?? "" }
    }

    /// Says which sender is you, or that none is (`nil`).
    func setOwner(chatID: Int64, sender: String?) throws {
        try database.prepare("UPDATE chat SET owner_sender = ?1, owner_chosen = 1 WHERE id = ?2")
            .bind(.optionalText(sender), .integer(chatID)).run()
    }

    func rename(chatID: Int64, title: String) throws {
        try database.prepare("UPDATE chat SET title = ?1 WHERE id = ?2").bind(.text(title), .integer(chatID)).run()
    }

    /// Deletes the chat, its messages and their index entries.
    func delete(chatID: Int64) throws {
        try database.prepare("DELETE FROM chat WHERE id = ?1").bind(.integer(chatID)).run()
    }

    // MARK: - Import

    /// Reads an exported chat and stores it, or merges it into the same chat imported before.
    /// - Parameters:
    ///   - url: A `.zip` or `.txt` the app may read.
    ///   - knownOwners: Names you said were you in other chats: one of them among the senders answers "Chi sei?".
    ///   - progress: The fraction read, from 0 to 1, called often.
    func importChat(from url: URL, knownOwners: Set<String>, progress: @Sendable (Double) -> Void = { _ in }) throws -> ImportOutcome {
        let file = try ChatFile(url: url)
        do {
            return try database.transaction {
                try store(file, knownOwners: knownOwners, progress: progress)
            }
        } catch let error as ImportFailure {
            throw error
        } catch is CancellationError {
            throw CancellationError()
        } catch ZipError.tooLarge {
            throw ImportFailure.tooLarge
        } catch is ZipError {
            throw ImportFailure.damagedArchive
        } catch let error as SQLiteError {
            throw error
        } catch {
            throw ImportFailure.unreadableFile
        }
    }

    private func store(_ file: ChatFile, knownOwners: Set<String>, progress: (Double) -> Void) throws -> ImportOutcome {
        let now = Date.now.timeIntervalSince1970
        try database.prepare("""
        INSERT INTO chat (title, first_at, last_at, source_format, has_media, imported_at) VALUES ('', 0, 0, '', ?1, ?2)
        """).bind(.integer(file.hasMedia ? 1 : 0), .real(now)).run()
        let stagingID = database.lastInsertedRowID

        let insert = try database.prepare("""
        INSERT OR IGNORE INTO message (chat_id, sent_at, sender, text, kind, word_count, line_hash)
        VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)
        """)
        var hashes = LineHash()
        var messageCount = 0
        var rowCount = 0
        var firstAt = Double.infinity
        var lastAt = -Double.infinity
        let format = try WhatsAppParser().parse(file.source, progress: progress) { message in
            let sentAt = message.sentAt.timeIntervalSince1970
            try insert.bind(
                .integer(stagingID), .real(sentAt), .optionalText(message.sender), .text(message.text),
                .text(message.kind.rawValue), .integer(Int64(message.wordCount)), .integer(hashes.next(for: message))
            ).run()
            rowCount += 1
            if message.kind.isMessage {
                messageCount += 1
                firstAt = min(firstAt, sentAt)
                lastAt = max(lastAt, sentAt)
            }
        }
        guard messageCount > 0 else { throw ImportFailure.noMessages }

        let senders = try senders(chatID: stagingID)
        let title = file.title ?? senders.prefix(2).joined(separator: ", ")

        // The same chat imported before: the one sharing the most lines with this file, when they share
        // at least half of the file, twenty lines, or the name. A chance match never merges two chats.
        let overlap = try database.prepare("""
        SELECT m.chat_id, COUNT(*), c.title FROM message s
        JOIN message m ON m.line_hash = s.line_hash AND m.chat_id != s.chat_id
        JOIN chat c ON c.id = m.chat_id
        WHERE s.chat_id = ?1
        GROUP BY m.chat_id ORDER BY COUNT(*) DESC LIMIT 1
        """).bind(.integer(stagingID)).map { (id: $0.int(0), shared: Int($0.int(1)), title: $0.text(2) ?? "") }.first

        let isSameChat = overlap.map { match in
            match.shared * 2 >= rowCount || match.shared >= 20 || match.title.localizedCaseInsensitiveCompare(title) == .orderedSame
        } ?? false

        let chatID: Int64
        let added: Int
        if let overlap, isSameChat {
            chatID = overlap.id
            let before = try storedMessageCount(chatID: chatID)
            try database.prepare("""
            INSERT OR IGNORE INTO message (chat_id, sent_at, sender, text, kind, word_count, line_hash)
            SELECT ?1, sent_at, sender, text, kind, word_count, line_hash FROM message WHERE chat_id = ?2 ORDER BY id
            """).bind(.integer(chatID), .integer(stagingID)).run()
            try database.prepare("DELETE FROM chat WHERE id = ?1").bind(.integer(stagingID)).run()
            added = try storedMessageCount(chatID: chatID) - before
            try database.prepare("""
            UPDATE chat SET first_at = MIN(first_at, ?1), last_at = MAX(last_at, ?2), imported_at = ?3,
                has_media = MAX(has_media, ?4) WHERE id = ?5
            """).bind(.real(firstAt), .real(lastAt), .real(now), .integer(file.hasMedia ? 1 : 0), .integer(chatID)).run()
        } else {
            chatID = stagingID
            added = messageCount
            try database.prepare("UPDATE chat SET title = ?1, first_at = ?2, last_at = ?3, source_format = ?4 WHERE id = ?5")
                .bind(.text(title), .real(firstAt), .real(lastAt), .text(format), .integer(chatID)).run()
        }

        // "Chi sei?": already answered for this chat, or answered by a name you gave in another one.
        let chat = try chat(id: chatID)
        let allSenders = try self.senders(chatID: chatID)
        var needsOwner = !(chat?.ownerChosen ?? false)
        if needsOwner {
            let known = allSenders.filter(knownOwners.contains)
            if known.count == 1 {
                try setOwner(chatID: chatID, sender: known[0])
                needsOwner = false
            }
        }
        return ImportOutcome(chatID: chatID, addedMessages: added, merged: chatID != stagingID, senders: allSenders, needsOwner: needsOwner)
    }

    private func storedMessageCount(chatID: Int64) throws -> Int {
        try database.prepare("SELECT COUNT(*) FROM message WHERE chat_id = ?1 AND kind != 'system'")
            .bind(.integer(chatID)).map { Int($0.int(0)) }.first ?? 0
    }

    // MARK: - Reading

    /// Every message between `start` and `end` (all when `nil`), oldest first.
    func records(chatID: Int64, from start: Date? = nil, to end: Date? = nil) throws -> [MessageRecord] {
        try database.prepare("""
        SELECT sent_at, sender, kind, word_count FROM message
        WHERE chat_id = ?1 AND sent_at >= ?2 AND sent_at <= ?3 ORDER BY sent_at, id
        """).bind(.integer(chatID), .real(Self.lower(start)), .real(Self.upper(end))).map { row in
            MessageRecord(
                sentAt: Date(timeIntervalSince1970: row.double(0)),
                sender: row.text(1),
                kind: MessageKind(rawValue: row.text(2) ?? "") ?? .text,
                wordCount: Int(row.int(3))
            )
        }
    }

    /// The text of every written message between `start` and `end`, with its author.
    func texts(chatID: Int64, from start: Date? = nil, to end: Date? = nil) throws -> [SenderText] {
        try database.prepare("""
        SELECT sender, text FROM message
        WHERE chat_id = ?1 AND kind = 'text' AND sender IS NOT NULL AND sent_at >= ?2 AND sent_at <= ?3
        """).bind(.integer(chatID), .real(Self.lower(start)), .real(Self.upper(end))).map { row in
            SenderText(sender: row.text(0) ?? "", text: row.text(1) ?? "")
        }
    }

    /// Messages that match `input` (see `SearchQuery`), newest first, and how many match in all.
    /// - Parameter sender: Only this author's messages, or everyone's when `nil`.
    func search(chatID: Int64, for input: String, sender: String? = nil, limit: Int = 200) throws -> (hits: [SearchHit], total: Int) {
        guard let match = SearchQuery.match(for: input) else { return ([], 0) }
        let filter = """
        FROM message_fts JOIN message m ON m.id = message_fts.rowid
        WHERE message_fts MATCH ?1 AND m.chat_id = ?2 AND (?3 IS NULL OR m.sender = ?3)
        """
        let parameters: [SQLiteValue] = [.text(match), .integer(chatID), .optionalText(sender)]
        let total = try database.prepare("SELECT COUNT(*) \(filter)").bind(parameters).map { Int($0.int(0)) }.first ?? 0
        let hits = try database.prepare("""
        SELECT m.id, m.sent_at, m.sender, snippet(message_fts, 0, char(1), char(2), '…', 24)
        \(filter) ORDER BY m.sent_at DESC, m.id DESC LIMIT \(limit)
        """).bind(parameters).map { row in
            SearchHit(id: row.int(0), sentAt: Date(timeIntervalSince1970: row.double(1)), sender: row.text(2) ?? "", snippet: row.text(3) ?? "")
        }
        return (hits, total)
    }

    private static func lower(_ date: Date?) -> Double { date?.timeIntervalSince1970 ?? -Double.greatestFiniteMagnitude }
    private static func upper(_ date: Date?) -> Double { date?.timeIntervalSince1970 ?? Double.greatestFiniteMagnitude }
}
