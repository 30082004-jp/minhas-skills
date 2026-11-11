#!/usr/bin/env bash
# Reconstrói skills/, licencas/ e INDICE.md a partir de fontes.conf (só linhas "copiar").
# Uso (mantenedor): bash scripts/atualizar-fontes.sh   → depois revise com: git diff --stat
set -euo pipefail
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
baixar_repo() { # repo commit -> imprime o diretório do checkout (reaproveita entre linhas)
  local dir="$TMP/$(echo "$1" | tr '/' '_')-$2"
  if [ ! -d "$dir" ]; then
    git -C "$TMP" init -q "$dir"
    git -C "$dir" fetch -q --depth 1 "https://github.com/$1" "$2"
    git -C "$dir" checkout -q FETCH_HEAD
  fi
  echo "$dir"
}
rm -rf "$RAIZ/skills" "$RAIZ/licencas"; mkdir -p "$RAIZ/skills" "$RAIZ/licencas"
ORIGEM="$TMP/origem.tsv"; : > "$ORIGEM"
while IFS='|' read -r tipo repo commit padrao; do
  case "$tipo" in ''|\#*) continue ;; esac
  [ "$tipo" = "copiar" ] || continue
  dir="$(baixar_repo "$repo" "$commit")"
  for lic in "$dir"/LICENSE*; do [ -f "$lic" ] && cp "$lic" "$RAIZ/licencas/$(echo "$repo" | tr '/' '_').txt"; done
  achou=0
  for src in "$dir"/$padrao; do
    [ -f "$src/SKILL.md" ] || continue
    nome="$(basename "$src")"
    if [ -e "$RAIZ/skills/$nome" ]; then echo "ERRO: skill duplicada: $nome ($repo)" >&2; exit 1; fi
    cp -R "$src" "$RAIZ/skills/$nome"; achou=1
    printf '%s\t%s\t%s\n' "$nome" "$repo" "${commit:0:7}" >> "$ORIGEM"
  done
  [ "$achou" = 1 ] || { echo "ERRO: nada encontrado em $repo:$padrao" >&2; exit 1; }
done < "$RAIZ/fontes.conf"
{
  echo "# Índice das skills incluídas"
  echo
  echo "Gerado por \`scripts/atualizar-fontes.sh\`. Não edite à mão."
  echo
  echo "| Skill | Origem | Commit | Descrição |"
  echo "|---|---|---|---|"
  sort "$ORIGEM" | while IFS=$'\t' read -r nome repo c; do
    desc="$(awk '/^---$/{n++; next} n==1 && /^description:/{sub(/^description: *"?/,""); sub(/"$/,""); print; exit}' "$RAIZ/skills/$nome/SKILL.md" | cut -c1-140 | tr '|' '/')"
    echo "| \`$nome\` | [$repo](https://github.com/$repo) | \`$c\` | $desc |"
  done
  echo
  echo "Baixadas na instalação (sem licença de redistribuição, não ficam neste repositório):"
  echo
  grep -E '^baixar\|' "$RAIZ/fontes.conf" | while IFS='|' read -r _ repo commit padrao; do
    echo "- [$repo](https://github.com/$repo) \`${commit:0:7}\` — \`$padrao\`"
  done
} > "$RAIZ/INDICE.md"
echo "OK: $(ls "$RAIZ/skills" | wc -l | tr -d ' ') skills em skills/"
