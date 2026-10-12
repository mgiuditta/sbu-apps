# Target minimo iOS 17, non iOS 26

Le **App Sbu** partono da iOS 17 perché sono gratuite e devono arrivare a più iPhone possibile, compresi quelli che non aggiornano. iOS 17 è il minimo che dà Observation (`@Observable`), `sensoryFeedback` e i string catalog. Le skill Swift del repo assumono iOS 26 come default: dove suggeriscono API solo iOS 18+ (per esempio `Tab`) vale questo ADR. Alzare il minimo è facile; abbassarlo dopo aver adottato API nuove non lo è.
