#!/bin/bash

INPUT_FILE="targets.txt"
OUTPUT_DIR="output"
THREADS=3

# ✅ arg

while getopts "i:t:e:" opt; do
  case $opt in
    i) INPUT_FILE="$OPTARG" ;;
    t) THREADS="$OPTARG" ;;
    e) EXCLUDE_FILE="$OPTARG" ;;
  esac
done


EXCLUDE_REGEX=""

if [[ -f "$EXCLUDE_FILE" ]]; then
    echo "[INFO] loading exclude list: $EXCLUDE_FILE"

    EXCLUDE_REGEX=$(cat "$EXCLUDE_FILE" | tr '\n' '|' | sed 's/|$//')
fi


if [[ ! -f "$INPUT_FILE" ]]; then
  echo "[!] File tidak ditemukan: $INPUT_FILE"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "[START] ELITE HUNTER 💀"

sanitize_filename() {
    echo "$1" | sed 's|https\?://||' | sed 's|[^a-zA-Z0-9]|_|g'
}

export -f sanitize_filename


crawl_target() {

    URL=$1
    DOMAIN=$(echo $URL | sed 's|https\?://||' | cut -d/ -f1)
    FILE="$OUTPUT_DIR/$DOMAIN.jsonl"

    echo "[RUNNING] $DOMAIN"

    # ✅ KATANA FULL
    katana -u "$URL" \
        -d 5 \
        -jc \
        -jsl \
        -kf all \
        -hl \
        -xhr \
        -system-chrome \
        -system-chrome-path /usr/bin/chromium \
        -no-sandbox \
        -j \
        -silent \
        -ob -or \
        -o "$FILE" \
        > /dev/null 2>&1

    mkdir -p "$OUTPUT_DIR/$DOMAIN"

    echo "[EXTRACT] $DOMAIN"

    # ✅ extract semua URL
    jq -r '
      .request.endpoint?,
      .url?,
      (.xhr[]?.url)
    ' "$FILE" 2>/dev/null \
    | grep -v '^null$' \
    | sort -u \
    | {
        if [[ -n "$EXCLUDE_REGEX" ]]; then
            echo "$link" | grep -Eq "$EXCLUDE_REGEX" && continue
        else
            cat
        fi
    } \
    > "$OUTPUT_DIR/$DOMAIN-urls.txt"

    # ✅ PARAMETER MINING 🔥
    grep -E "\?.*=" "$OUTPUT_DIR/$DOMAIN-urls.txt" \
        > "$OUTPUT_DIR/$DOMAIN-params.txt"

    sed -E 's/\?.*/?FUZZ=1/' "$OUTPUT_DIR/$DOMAIN-params.txt" \
        | sort -u > "$OUTPUT_DIR/$DOMAIN-fuzz.txt"

    echo "[PARAM] $(wc -l < "$OUTPUT_DIR/$DOMAIN-params.txt") param found"

    # ✅ DOWNLOAD CLEAN FILE 🔥
    echo "[DOWNLOAD] $DOMAIN"

    COUNT=0

    while read -r link; do

        [[ "$link" =~ \.(png|jpg|jpeg|gif|css|svg|woff|ico)$ ]] && continue

        NAME=$(echo "$link" | sed 's|https\?://||' | sed 's|[^a-zA-Z0-9]|_|g')

        if [[ "$link" =~ \.js($|\?) ]]; then
            EXT=".js"
        else
            EXT=".html"
        fi

        STATUS=$(curl -m 10 -s -o /dev/null -w "%{http_code}" "$link")

        if [[ "$STATUS" == "200" ]]; then
            curl -s "$link" -o "$OUTPUT_DIR/$DOMAIN/$NAME$EXT"
            ((COUNT++))
        fi

    done < "$OUTPUT_DIR/$DOMAIN-urls.txt"

    # ✅ ENDPOINT PARSING (UPGRADED REGEX)
    
    grep -rhoE "(https?://[^\"' ]+|/[a-zA-Z0-9/_-]{3,})" "$OUTPUT_DIR/$DOMAIN" 2>/dev/null \
    | grep -vE "\.(png|jpg|css|svg)" \
    | {
        if [[ -n "$EXCLUDE_REGEX" ]]; then
            grep -Ev "$EXCLUDE_REGEX"
        else
            cat
        fi
    } \
    | sort -u > "$OUTPUT_DIR/$DOMAIN-endpoints.txt"


    # ✅ HIGH VALUE 🔥
    grep -Ei "create|update|delete|admin|login|auth|debug|api" \
        "$OUTPUT_DIR/$DOMAIN-endpoints.txt" \
        > "$OUTPUT_DIR/$DOMAIN-highvalue.txt"

    # ✅ REQUEST LIST (BURP/FFUF READY) 🔥
    while read -r url; do
        echo "GET $url" >> "$OUTPUT_DIR/$DOMAIN-requests.txt"
    done < "$OUTPUT_DIR/$DOMAIN-urls.txt"

    # ✅ SENSITIVE DATA 🔥

    # ✅ base secret extraction (key + value)
    
    grep -rHoEi "(api[_-]?key|token|secret|password|jwt|bearer)[\"'\s:=]+[a-zA-Z0-9_\-\.=]{6,}" \
     "$OUTPUT_DIR/$DOMAIN" 2>/dev/null \
     > "$OUTPUT_DIR/$DOMAIN-secrets.txt"


    # ✅ JWT token extractor
    grep -rHoE "eyJ[a-zA-Z0-9_\-\.=]+" "$OUTPUT_DIR/$DOMAIN" 2>/dev/null \
     >> "$OUTPUT_DIR/$DOMAIN-secrets.txt"


    # ✅ Authorization header extractor
    grep -rHoEi "Authorization[\"' :]+Bearer[ ]+[a-zA-Z0-9_\-\.=]+" \
     "$OUTPUT_DIR/$DOMAIN" 2>/dev/null \
     >> "$OUTPUT_DIR/$DOMAIN-secrets.txt"


    # ✅ final clean (remove duplicate)
    sort -u "$OUTPUT_DIR/$DOMAIN-secrets.txt" \
     -o "$OUTPUT_DIR/$DOMAIN-secrets.txt"


    echo "[DONE] $DOMAIN"
    echo "  ├─ URLs        : $(wc -l < "$OUTPUT_DIR/$DOMAIN-urls.txt")"
    echo "  ├─ params      : $(wc -l < "$OUTPUT_DIR/$DOMAIN-params.txt")"
    echo "  ├─ endpoints   : $(wc -l < "$OUTPUT_DIR/$DOMAIN-endpoints.txt")"
    echo "  ├─ highvalue   : $(wc -l < "$OUTPUT_DIR/$DOMAIN-highvalue.txt")"
    echo "  ├─ files       : $COUNT"
    echo "-----------------------------"
}

export -f crawl_target
export OUTPUT_DIR sanitize_filename

cat "$INPUT_FILE" | xargs -P $THREADS -I {} bash -c 'crawl_target "$@"' _ {}

echo "[✓] DONE - HUNT READY 💀"
``
