#!/usr/bin/env bash
# Instala as skills deste repositório (Linux, macOS, nuvem, dev containers).
#
#   bash instalar.sh                      → instala em ~/.claude/skills (Claude Code, nível de usuário)
#   bash instalar.sh --destino DIR        → instala em outra pasta (ex.: .claude/skills de um projeto)
#   bash instalar.sh --sem-baixar         → só as skills copiadas aqui (não acessa outros repositórios)
#
# Atualiza skills de mesmo nome que já existam no destino; não mexe nas demais.
set -uo pipefail
RAIZ="$(cd "$(dirname "$0")" && pwd)"
DESTINO="${HOME}/.claude/skills"; BAIXAR=1
while [ $# -gt 0 ]; do
  case "$1" in
    --destino) DESTINO="$2"; shift 2 ;;
    --sem-baixar) BAIXAR=0; shift ;;
    -h|--ajuda|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "Opção desconhecida: $1 (use --ajuda)" >&2; exit 2 ;;
  esac
done
mkdir -p "$DESTINO" || { echo "ERRO: não consegui criar $DESTINO" >&2; exit 1; }
copiar() { # origem_dir -> destino/<nome>, substituindo a versão anterior
  local nome; nome="$(basename "$1")"
  rm -rf "${DESTINO:?}/$nome" && cp -R "$1" "$DESTINO/$nome"
}
n=0
for s in "$RAIZ"/skills/*/; do copiar "${s%/}" && n=$((n+1)); done
echo "✓ $n skills copiadas para $DESTINO"
falhas=0
if [ "$BAIXAR" = 1 ]; then
  while IFS='|' read -r tipo repo commit padrao; do
    case "$tipo" in baixar) ;; *) continue ;; esac
    tmp="$(mktemp -d)"
    if git -C "$tmp" init -q && git -C "$tmp" fetch -q --depth 1 "https://github.com/$repo" "$commit" \
       && git -C "$tmp" checkout -q FETCH_HEAD; then
      m=0; for src in "$tmp"/$padrao; do [ -d "$src" ] && copiar "$src" && m=$((m+1)); done
      echo "✓ $m itens de $repo (${commit:0:7})"
    else
      echo "AVISO: não consegui baixar $repo (${commit:0:7}); siga sem ele." >&2; falhas=$((falhas+1))
    fi
    rm -rf "$tmp"
  done < "$RAIZ/fontes.conf"
fi
echo "Pronto. Reinicie o Claude Code para carregar as skills."
[ "$falhas" = 0 ] || exit 3
