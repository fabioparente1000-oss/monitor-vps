#!/usr/bin/env bash
# Checa de FORA da VPS (GitHub Actions, a cada 10 min) se os endereços respondem. Se algum
# cair, abre um aviso (issue) neste repositório: o GitHub manda e-mail e notificação no app.
# Quando tudo volta, fecha o aviso com um comentário (outro e-mail). Um aviso por queda, não
# um por checagem. Os alertas por WhatsApp rodam dentro da própria VPS; este funciona mesmo
# com a VPS inteira fora do ar.
set -uo pipefail

declare -A URL=(
  [Ana]=https://agente.drfabioparente.com.br/health
  [MãeBebe]=https://api.cegonhadourada.com.br/health
  [Transcritor]=https://agente.drfabioparente.com.br/transcritor/_stcore/health
)
NOMES=(Ana MãeBebe Transcritor)

fora=()
for nome in "${NOMES[@]}"; do
  ok=0
  for _ in 1 2 3; do   # 3 tentativas em ~40 s: uma oscilação de rede não vira alarme
    codigo=$(curl -s -o /dev/null -m 15 -w '%{http_code}' "${URL[$nome]}")
    if [[ "$codigo" =~ ^[23] ]]; then ok=1; break; fi
    sleep 20
  done
  if [ "${SIMULAR_QUEDA:-false}" = true ] && [ "$nome" = Ana ]; then ok=0; codigo=teste; fi
  if [ "$ok" = 1 ]; then echo "ok    $nome"; else echo "FORA  $nome ($codigo)"; fora+=("$nome"); fi
done

quando=$(TZ=America/Sao_Paulo date '+%d/%m às %H:%M')
aberto=$(gh issue list --state open --label fora-do-ar --json number --jq '.[0].number // empty')

if [ ${#fora[@]} -gt 0 ] && [ -z "$aberto" ]; then
  titulo="🔴 Fora do ar: ${fora[*]}"
  [ ${#fora[@]} -eq ${#NOMES[@]} ] && titulo="🔴 VPS fora do ar? Nenhum endereço responde"
  [ "${SIMULAR_QUEDA:-false}" = true ] && titulo="🧪 Teste do monitor: ${fora[*]}"
  url=$(gh issue create --label fora-do-ar --title "$titulo" --body "Detectado de fora da VPS em $quando (3 tentativas em 40 s).

Painel: https://agente.drfabioparente.com.br/central/
Hostinger: https://hpanel.hostinger.com/

Este aviso fecha sozinho quando tudo voltar.")
  echo "$url"
  aberto=${url##*/}   # a listagem do GitHub demora a enxergar um aviso recém-criado
fi

# Tudo no ar (ou fim do teste): fecha o aviso aberto
if [ -n "$aberto" ] && { [ ${#fora[@]} -eq 0 ] || [ "${SIMULAR_QUEDA:-false}" = true ]; }; then
  gh issue close "$aberto" --comment "🟢 Tudo no ar de novo em $quando."
fi
exit 0
