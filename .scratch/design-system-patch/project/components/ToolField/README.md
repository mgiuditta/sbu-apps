# ToolField
La schermata strumento: un campo pieno `field-<app>`, la cifra `stat-hero` in `on-field` al centro, un'etichetta `caption` in `on-field-muted` sopra, una riga di pill `field-control` sotto. Modello: le schermate tuner e metronomo di Guitar Wiz (ADA 2026).

**Il consumatore fornisce** l'app (quindi il campo e l'accento), etichetta, valore formattato, unità, un eventuale grafico o indicatore, e le pill con la loro azione.

- Una sola `ToolField` per app: è la schermata principale, radice del `NavigationStack`. Niente tab bar. Le altre schermate sono su `surface`.
- Il campo è identico in light e dark: la schermata strumento è sempre scura. In SwiftUI: `.preferredColorScheme(.dark)` solo su questa view, `.tint(accent.dark)`.
- Il grafico o l'indicatore (curva dei decibel, bolla della livella, anello dello streak) è in `accent-<app>` (valore dark) sopra il campo; la cifra gli sta sopra o accanto, mai dentro.
- Le pill: `radius-pill`, testo `subheadline` in `on-field`, fondo `field-control`; selezionata `field-control-active` e peso 600. Massimo cinque in una riga, altrimenti sono un segmented control di sistema.
- Sopra il campo c'è la toolbar di sistema (Liquid Glass da iOS 26): titolo inline in `on-field`, ingranaggio in `on-field` in alto a destra che apre le Impostazioni in un foglio. In fondo `space-8` di respiro, nessun elemento fisso a filo del bordo.
- SwiftUI: `ZStack { Color.field.ignoresSafeArea(); VStack { … } }`, cifra con `.font(.system(size: 64, weight: .medium, design: .monospaced)).monospacedDigit()`.
