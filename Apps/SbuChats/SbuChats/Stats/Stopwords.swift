import NaturalLanguage

/// Words too common to say anything about a chat, in the six languages the ranking knows.
nonisolated enum Stopwords {
    /// The stopwords for `language`, or every list together for a language not among the six.
    static func words(for language: NLLanguage?) -> Set<String> {
        switch language {
        case .italian: italian
        case .english: english
        case .german: german
        case .spanish: spanish
        case .french: french
        case .portuguese: portuguese
        default: italian.union(english).union(german).union(spanish).union(french).union(portuguese)
        }
    }

    private static func list(_ words: String) -> Set<String> {
        Set(words.split(whereSeparator: \.isWhitespace).map(String.init))
    }

    static let italian = list("""
    a ad al alla alle allo ai agli all anche ancora che chi ci col come con cosa così cui da dal dalla dalle dai degli dei del \
    della delle dello di dove e ed è era erano essere fa fare gli ha hai hanno ho i il in io la le lei li lo loro lui ma me \
    mi mia mie miei mio ne nei nel nella nelle nello no non noi o per perché più poi qua quale quando quanto quel quella \
    quelle quelli quello questa queste questi questo qui se sei si sia siamo siete sì sono sta stai sto su sua sue sugli \
    sui sul sulla suo suoi te ti tra tu tua tue tuo tuoi tutto tutti un una uno vi voi c l un' l' c' po' perche'
    """)

    static let english = list("""
    a about after all also am an and any are as at be because been but by can could did do does doing don't for from \
    get got had has have he her here him his how i i'm if in into is it it's its just like me my no not now of on one \
    or our out so some than that that's the their them then there they this to too up us was we were what when where \
    which who will with would yeah yes you your you're im dont
    """)

    static let german = list("""
    aber alle als also am an auch auf aus bei bin bis bist da das dass dem den der des die dir doch du ein eine einem \
    einen einer er es für hab habe hast hat ich ihr im in ist ja jetzt kann mal man mich mir mit nach nicht noch nur \
    oder schon sein sich sie sind so und uns von war was wie wir wird zu zum zur
    """)

    static let spanish = list("""
    a al algo como con de del el ella ellos en es esa ese eso esta este esto estoy fue ha hay la las le lo los me mi \
    muy más nada ni no nos o para pero por porque que qué se si sí su sus te ti todo tu tú un una uno y ya yo
    """)

    static let french = list("""
    à a ai au aux avec bien c ça ce ces dans de des du elle en est et être il ils j je la le les leur lui ma mais me \
    mes moi mon ne nous on ou où par pas pour qu que qui sa se ses si son sur ta te tes toi ton tu un une vous y \
    c'est j'ai
    """)

    static let portuguese = list("""
    a ao as com como da das de do dos e é ela ele em então essa esse está eu foi isso já mais mas me meu minha muito \
    na não nas no nos o os para pra por que se sem sim só sua seu também te tem tu um uma você vc
    """)
}
