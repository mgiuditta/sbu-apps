import Testing
@testable import SbuChats

struct ChatTitleTests {
    @Test(arguments: [
        ("WhatsApp Chat - Anna Rossi.zip", "Anna Rossi"),
        ("WhatsApp Chat with Marta.txt", "Marta"),
        ("Chat WhatsApp con Calcetto del giovedì.txt", "Calcetto del giovedì"),
        ("WhatsApp-Chat mit Jörg.txt", "Jörg"),
        ("WhatsApp Chat - Anna Rossi (1).zip", "Anna Rossi"),
        ("Famiglia.txt", "Famiglia"),
    ])
    func dropsTheExportPrefix(fileName: String, title: String) {
        #expect(ChatTitle.title(fromFileName: fileName) == title)
    }

    @Test(arguments: ["_chat.txt", "WhatsApp Chat.zip", ".txt"])
    func saysNothingWhenTheNameHasNoChat(fileName: String) {
        #expect(ChatTitle.title(fromFileName: fileName) == nil)
    }
}
