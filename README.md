# minhas-skills

Coleção pessoal de skills para o Claude Code (e outros agentes compatíveis com Agent
Skills), **fixadas em versões revisadas**, com instaladores para qualquer máquina ou nuvem.

| Conjunto | Skills | Licença | Como entra |
|---|---|---|---|
| [mattpocock/skills](https://github.com/mattpocock/skills) | `grill-me`, `grilling` | MIT | copiado em `skills/` |
| [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) | `planning-with-files` | MIT | copiado em `skills/` |
| [obra/superpowers](https://github.com/obra/superpowers) | 15 skills (brainstorming, TDD, debugging, planos…) | MIT | copiado em `skills/` |
| [levnikolaevich/claude-code-skills](https://github.com/levnikolaevich/claude-code-skills) | 41 skills `ln-*` das 9 suítes | MIT | copiado em `skills/` |
| [dralgorhythm/claude-agentic-framework](https://github.com/dralgorhythm/claude-agentic-framework) | 21 skills (`/architect`, `/builder`, `swarm-*`…) | **sem licença** | baixado da fonte na instalação |

Lista completa com descrições: [INDICE.md](INDICE.md). Versões fixadas: [fontes.conf](fontes.conf).
Licenças das fontes copiadas: [licencas/](licencas/).

## Instalar

### Linux, macOS, nuvem, dev container

```bash
git clone --depth 1 https://github.com/30082004-jp/minhas-skills
```

```bash
bash minhas-skills/instalar.sh
```

Instala em `~/.claude/skills` (vale para todos os projetos daquele usuário). Opções:
`--destino DIR` (outra pasta, ex. `.claude/skills` de um projeto ou a pasta de skills de
outro agente) e `--sem-baixar` (só o que está neste repositório).

### Windows (PowerShell)

```powershell
git clone --depth 1 https://github.com/30082004-jp/minhas-skills
```

```powershell
powershell -ExecutionPolicy Bypass -File .\minhas-skills\instalar.ps1
```

Opções: `-Destino C:\pasta` e `-SemBaixar`. Requer `git` no PATH.

### Ambiente de nuvem do Claude Code (script de inicialização)

Em claude.ai/code, no menu do ambiente → **Edit** → **Setup script**, uma linha só:

```bash
rm -rf /tmp/minhas-skills; git clone -q --depth 1 https://github.com/30082004-jp/minhas-skills /tmp/minhas-skills && bash /tmp/minhas-skills/instalar.sh || true
```

### GitHub Codespaces / dev containers

No `devcontainer.json`:

```json
"postCreateCommand": "git clone -q --depth 1 https://github.com/30082004-jp/minhas-skills /tmp/minhas-skills && bash /tmp/minhas-skills/instalar.sh"
```

Depois de instalar, reinicie o Claude Code. Rodar de novo atualiza as skills de mesmo
nome e não mexe nas outras.

## Atualizar ou incluir skills (mantenedor)

1. Edite `fontes.conf` (novo commit revisado ou nova linha).
2. Rode `bash scripts/atualizar-fontes.sh` — reconstrói `skills/`, `licencas/` e `INDICE.md`.
3. Revise o diff (`git diff --stat`, e com atenção `scripts/` e blocos `hooks:` nos `SKILL.md`).
4. Faça o commit. Fontes sem licença de redistribuição usam o tipo `baixar`.

## Cuidados

- **Quantidade:** são ~80 skills; a lista de nomes e descrições ocupa contexto em toda
  sessão. Há sobreposições (ex.: `/architect` × `ln-23`, `writing-adrs` × `ln-24`).
- **Hooks:** `planning-with-files` declara hooks (rodam scripts locais da própria pasta
  enquanto a skill está ativa). As demais não declaram hooks.
- **Servidor local:** `brainstorming` (modo visual) sobe um servidor HTTP local.
- **Versões fixas:** nada muda sem você editar `fontes.conf` e rodar o atualizador.
