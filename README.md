# monitor-vps

Aviso externo de queda dos serviços da VPS da clínica. A cada 10 minutos o GitHub Actions
testa, de fora da VPS, se os endereços respondem:

- Ana (WhatsApp do consultório): `agente.drfabioparente.com.br/health`
- MãeBebe: `api.cegonhadourada.com.br/health`
- Transcritor: `agente.drfabioparente.com.br/transcritor/_stcore/health`

Se algum cair (3 tentativas em 40 s), abre um aviso em **Issues** com o rótulo `fora-do-ar`
(chega por e-mail e no app do GitHub). Quando tudo volta, o aviso fecha sozinho com um
comentário. Os alertas por WhatsApp rodam dentro da própria VPS (repositório `infra-vps`);
este é o que funciona mesmo com a VPS inteira fora do ar.

Repositório público de propósito: o GitHub Actions é gratuito sem limite de minutos em
repositório público, e aqui só há endereços que já são públicos. O `manter-ativo` faz um
commit por mês, porque o GitHub desliga agendamentos de repositório público parado há 60 dias.

Testar: aba Actions → "Monitor da VPS" → Run workflow → marcar "simular queda".
