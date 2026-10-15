"""Writes the synthetic exports the Sbu Chats tests read, into SbuChatsTests/Fixtures.

Invented people and text only: real chats never go in the repo (issue #467).
Run: python3 Apps/SbuChats/scripts/make_fixtures.py
"""
import os
import zipfile

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "SbuChatsTests", "Fixtures")
LRM = "‎"
NNBSP = " "


def write(name, lines, crlf=False, bom=False):
    end = "\r\n" if crlf else "\n"
    data = (end.join(lines) + end).encode("utf-8")
    if bom:
        data = b"\xef\xbb\xbf" + data
    with open(os.path.join(OUT, name), "wb") as f:
        f.write(data)
    return data


os.makedirs(OUT, exist_ok=True)

# iPhone, Italian, 24 h, day first (15 > 12 settles it), CRLF.
ios_it = [
    f"[14/03/24, 09:15:02] Anna Rossi: {LRM}I messaggi e le chiamate sono crittografati end-to-end. Nessuno al di fuori di questa chat, nemmeno WhatsApp, può leggerli né ascoltarli.",
    "[14/03/24, 09:15:02] Anna Rossi: Ciao Luca, ci vediamo stasera?",
    "[14/03/24, 09:20:40] Luca Bianchi: Sì! Alle otto al solito posto",
    "[14/03/24, 09:21:05] Luca Bianchi: Porto io il vino 🍷",
    "[14/03/24, 09:30:00] Anna Rossi: Perfetto",
    "anzi, porta anche il pane",
    "e il dolce 🎂",
    f"{LRM}[14/03/24, 09:31:10] Anna Rossi: {LRM}immagine omessa",
    "[15/03/24, 22:10:00] Luca Bianchi: Grazie per la cena 👍🏽👍🏽",
    f"[15/03/24, 22:12:30] Anna Rossi: {LRM}Questo messaggio è stato eliminato.",
    f"[16/03/24, 08:00:00] Anna Rossi: Buongiorno ☀️ {LRM}<Questo messaggio è stato modificato>",
    f"[16/03/24, 08:05:00] Luca Bianchi: {LRM}Chiamata vocale persa",
    "[16/03/24, 08:06:00] Luca Bianchi: Buongiorno a te 👨‍👩‍👧",
]
write("ios-it-24h.txt", ios_it, crlf=True)

# iPhone, English (US), 12 h with U+202F before AM/PM, month first (13 settles it).
ios_en = [
    f"[3/12/24, 9:41:07{NNBSP}PM] Sam Taylor: Hey, are we still on for Friday?",
    f"[3/12/24, 9:45:00{NNBSP}PM] Jo Park: Yes, 7pm works",
    f"[3/13/24, 12:05:10{NNBSP}AM] Sam Taylor: {LRM}image omitted",
    f"[3/13/24, 12:30:00{NNBSP}PM] Jo Park: {LRM}<attached: 00000012-PHOTO-2024-03-13-12-30-00.jpg>",
    f"[3/13/24, 1:00:00{NNBSP}PM] Sam Taylor: Nice photo",
    "where was that?",
    f"[3/14/24, 8:00:00{NNBSP}AM] Jo Park: {LRM}This message was deleted.",
]
write("ios-en-12h.txt", ios_en)

# Android, Italian, 24 h, two-digit year, no seconds, LF, byte order mark, a system line without author.
android_it = [
    "05/01/25, 10:00 - I messaggi e le chiamate sono crittografati end-to-end. Nessuno al di fuori di questa chat, nemmeno WhatsApp, può leggerli né ascoltarli. Tocca per saperne di più.",
    "05/01/25, 10:01 - Marta: Buon anno!",
    "05/01/25, 10:02 - Paolo: Anche a te 🎉",
    "05/01/25, 10:03 - Marta: <Media omessi>",
    "13/01/25, 18:30 - Paolo: IMG-20250113-WA0001.jpg (file allegato)",
    "13/01/25, 18:31 - Paolo: Guarda che tramonto",
    "e che colori",
    "13/01/25, 18:40 - Marta: Questo messaggio è stato eliminato",
]
write("android-it-24h.txt", android_it, bom=True)

# Android, English (US), 12 h, month first.
android_en = [
    "1/5/25, 9:41 PM - Messages and calls are end-to-end encrypted.",
    "1/5/25, 9:42 PM - Chris: Did you see the game?",
    "1/5/25, 9:50 PM - Dana: <Media omitted>",
    "1/13/25, 7:00 AM - Chris: Morning",
    "1/13/25, 12:15 PM - Dana: Lunch?",
]
write("android-en-12h.txt", android_en)

# Every field at most 12: only the chronology tells month-first from day-first.
write("ambiguous-mdy.txt", [
    "[1/2/24, 10:00:00] Ada: one",
    "[1/3/24, 10:00:00] Bea: two",
    "[1/4/24, 10:00:00] Ada: three",
    "[1/10/24, 10:00:00] Bea: four",
    "[2/1/24, 10:00:00] Ada: five",
])

# Not a chat.
write("not-a-chat.txt", ["Lista della spesa", "latte", "uova"])

# Archives: iPhone with media (DEFLATE), Android without media (stored), ZIP64, photos only.
ios_text = ("\r\n".join(ios_it) + "\r\n").encode("utf-8")
with zipfile.ZipFile(os.path.join(OUT, "WhatsApp Chat - Anna Rossi.zip"), "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("_chat.txt", ios_text)
    z.writestr("00000003-PHOTO-2024-03-14-09-31-10.jpg", b"\xff\xd8\xff not a real photo")
    z.writestr("__MACOSX/._chat.txt", b"resource fork")
with zipfile.ZipFile(os.path.join(OUT, "android-stored.zip"), "w", zipfile.ZIP_STORED) as z:
    z.writestr("WhatsApp Chat with Marta.txt", ("\n".join(android_it) + "\n").encode("utf-8"))
zip64 = os.path.join(OUT, "zip64.zip")
with zipfile.ZipFile(zip64, "w", zipfile.ZIP_DEFLATED, allowZip64=True) as z:
    with z.open("_chat.txt", "w", force_zip64=True) as f:
        f.write(ios_text)
# Python writes the 64-bit end records only past the 32-bit limits: add them, as big exports have,
# and point the classic end record at them.
data = open(zip64, "rb").read()
end = data.rfind(b"PK\x05\x06")
count = int.from_bytes(data[end + 10:end + 12], "little")
cd_size = int.from_bytes(data[end + 12:end + 16], "little")
cd_offset = int.from_bytes(data[end + 16:end + 20], "little")
end64_offset = cd_offset + cd_size
end64 = (b"PK\x06\x06" + (44).to_bytes(8, "little") + (45).to_bytes(2, "little") * 2 + bytes(8)
         + count.to_bytes(8, "little") * 2 + cd_size.to_bytes(8, "little") + cd_offset.to_bytes(8, "little"))
locator = b"PK\x06\x07" + bytes(4) + end64_offset.to_bytes(8, "little") + (1).to_bytes(4, "little")
classic = b"PK\x05\x06" + bytes(4) + b"\xff\xff" * 2 + b"\xff\xff\xff\xff" * 2 + bytes(2)
with open(zip64, "wb") as f:
    f.write(data[:end64_offset] + end64 + locator + classic)
with zipfile.ZipFile(os.path.join(OUT, "photos-only.zip"), "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("IMG-20250113-WA0001.jpg", b"\xff\xd8\xff not a real photo")

# Hostile archives. A ratio bomb: 8 MB of the same byte deflates more than a thousand times.
with zipfile.ZipFile(os.path.join(OUT, "bomb-ratio.zip"), "w", zipfile.ZIP_DEFLATED, compresslevel=9) as z:
    z.writestr("_chat.txt", b"[1/2/24, 10:00:00] Ada: " + b"a" * (8 * 1024 * 1024))

# A lying bomb: 1 MB of text declared as 100 bytes in both headers, so the ratio looks harmless.
lying = os.path.join(OUT, "bomb-lying-size.zip")
with zipfile.ZipFile(lying, "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("_chat.txt", ("[1/2/24, 10:00:00] Ada: ciao\n" * 36000).encode("utf-8"))
data = bytearray(open(lying, "rb").read())
local_size_at = 22  # uncompressed size in the local header
data[local_size_at:local_size_at + 4] = (100).to_bytes(4, "little")
central = data.rfind(b"PK\x01\x02")
data[central + 24:central + 28] = (100).to_bytes(4, "little")
open(lying, "wb").write(bytes(data))

# A newer export of the iPhone chat: the two oldest lines cut by the export limit, three new messages
# (two identical ones in the same minute, which must both stay).
write("ios-it-24h-newer.txt", ios_it[2:] + [
    "[17/03/24, 19:00:00] Anna Rossi: Domani cinema?",
    "[17/03/24, 19:02:00] Luca Bianchi: Volentieri",
    "[17/03/24, 19:02:00] Luca Bianchi: Volentieri",
], crlf=True)
