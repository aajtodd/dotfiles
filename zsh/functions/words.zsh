#@@ words : word lookup (definitions, synonyms, antonyms)
# Uses the free dictionaryapi.dev JSON API (no key). Shadows the `dict` protocol
# client if installed; this wrapper uses curl+jq instead.

#@ dict : define a word  (-s synonyms, -a antonyms)
dict() {
    local mode=def
    case "${1:-}" in
        -s) mode=syn; shift ;;
        -a) mode=ant; shift ;;
        -*) print -u2 "dict: usage: dict [-s|-a] <word>"; return 1 ;;
    esac
    local word="${1:-}"
    [ -n "$word" ] || { print -u2 "dict: usage: dict [-s|-a] <word>"; return 1; }
    command -v jq   >/dev/null 2>&1 || { print -u2 "dict: needs jq"; return 1; }
    command -v curl >/dev/null 2>&1 || { print -u2 "dict: needs curl"; return 1; }
    local json
    json="$(curl -fsS "https://api.dictionaryapi.dev/api/v2/entries/en/${word}" 2>/dev/null)" \
        || { print -u2 "dict: lookup failed (offline, or no entry for '$word')"; return 1; }
    # The API returns a JSON object (not array) when there's no match.
    if print -r -- "$json" | jq -e 'type == "object"' >/dev/null 2>&1; then
        print -u2 "dict: no entry for '$word'"; return 1
    fi
    case "$mode" in
        def) print -r -- "$json" | jq -r '.[0].meanings[]
                | "\(.partOfSpeech):", (.definitions[] | "  • \(.definition)")' ;;
        syn) print -r -- "$json" | jq -r '[.[].meanings[]
                | .synonyms[], .definitions[].synonyms[]] | unique | .[]' \
                | { grep . || print -u2 "dict: no synonyms listed for '$word'"; } ;;
        ant) print -r -- "$json" | jq -r '[.[].meanings[]
                | .antonyms[], .definitions[].antonyms[]] | unique | .[]' \
                | { grep . || print -u2 "dict: no antonyms listed for '$word'"; } ;;
    esac
}
