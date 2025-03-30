# 🔁 Guia de Comparações Apex – v2025 (Mentalidade Mamba)

📎 **Shortlink oficial:** [bit.ly/ComparacaoApex](https://bit.ly/ComparacaoApex)

> “Nenhuma refatoração é legítima sem comparação explícita, revisão formal e equivalência comprovada.” – Mentalidade Mamba 🧠🔥

Este guia define como documentar, revisar e validar refatorações em Apex com segurança, clareza e rastreabilidade.

---

## 📚 Guias obrigatórios relacionados

- 📘 [Guia Master de Arquitetura](https://bit.ly/GuiaApexMamba)
- 🔍 [Guia de Revisão](https://bit.ly/GuiaApexRevisao)
- 🧪 [Guia de Testes](https://bit.ly/GuiaTestsApex)
- ✅ [Guia de Equivalência Funcional](https://bit.ly/ConfirmacaoApex)

---

## ✅ O que deve ser comparado

- Refatorações de qualquer método público ou `@TestVisible`
- Alterações de estrutura interna
- Mudança de fallback (ex: `null` → `Optional`, `LIMIT 1` → `RecordHelper`)
- Substituições de bloco de lógica por helper externo
- Renomeações de variáveis visíveis (exceto `private` sem impacto externo)
- Conversão de blocos `System.debug()` para `Logger.info()` ou `Logger.error()`

---

## ✅ Estrutura mínima de uma comparação

### ❌ Antes
```apex
Account acc = [SELECT Id, Name FROM Account WHERE Id = :id LIMIT 1];
```

### ✅ Depois
```apex
Account acc = (Account) RecordHelper.getById(Account.SObjectType, id, 'Id, Name');
```

> Toda comparação deve estar em comentário, PR, ou markdown dentro do branch.

---

## 📝 Template sugerido para Pull Requests

```markdown
### 🔄 Refatoração proposta

- Refatorado método `buscarConta()` para usar `RecordHelper.getById(...)`
- Adicionado fallback para `null`
- `@TestVisible` mantido para cobertura

### ✅ Antes
```apex
Account acc = [SELECT Id FROM Account WHERE Id = :id LIMIT 1];
```

### ✅ Depois
```apex
Account acc = (Account) RecordHelper.getById(Account.SObjectType, id, 'Id');
```

### 🧪 Testes
- Testes atualizados com `@TestSetup` e cobertura específica
- Adicionado caso para `id == null`

### 🔒 Equivalência funcional mantida
✔️ Confirmado via [bit.ly/ConfirmacaoApex](https://bit.ly/ConfirmacaoApex)
```

---

## ✅ Quando uma comparação é obrigatória?

| Situação                             | Obrigatório? |
|--------------------------------------|--------------|
| Alteração em método público          | ✅            |
| Troca de SELECT direto por helper    | ✅            |
| Refatoração em builder de teste      | ✅            |
| Alteração em lógica de log (`Logger`) | ✅            |
| Apenas mudança de espaçamento        | ❌            |
| Mudança em variável `private`        | ⚠️ contextual |
| Inclusão de assert em teste          | ⚠️ contextual |

---

## 📌 Dicas avançadas de comparação

- Use `git diff --word-diff` para destacar mudanças sutis
- Use `Side-by-Side` no VS Code para analisar refatorações longas
- Compare logs se alterou chamadas a `Logger` ou `RestServiceHelper`
- Mantenha os blocos separados por tipo:
  - `SELECT`
  - `Logger`
  - `Branch / if`
  - `Serialização`

---

## 🔗 Integrações úteis

| Guia                           | Contribuição                                  |
|--------------------------------|-----------------------------------------------|
| [GuiaLoggerApex](https://bit.ly/GuiaLoggerApex)   | Alvo comum de refatoração                     |
| [GuiaTestsApex](https://bit.ly/GuiaTestsApex)     | Validação de equivalência após mudanças       |
| [GuiaRestAPI](https://bit.ly/Guia_APIs_REST)      | Mudanças nos handlers precisam ser comparadas |

---

## 🧠 Final

> Toda melhoria precisa de prova.  
> Toda prova precisa de contexto.  
> Toda mudança precisa passar pela lupa da comparação.

📌 Refatoração sem comparação é improviso.  
🧱🧠🧪 #RefatoraComRaiz #AntesVsDepois #NadaMudaSemRastreabilidade



