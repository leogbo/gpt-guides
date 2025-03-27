# 🔍 Guia Rigoroso de Revisão Apex – v2025 (Mentalidade Mamba)

📎 **Shortlink oficial:** [bit.ly/GuiaApexRevisao](https://bit.ly/GuiaApexRevisao)

> “A revisão é o filtro final da excelência. Nenhuma linha sobrevive sem propósito.” – 🧠 Mentalidade Mamba

Este guia define os critérios obrigatórios para revisar código Apex com excelência institucional. Toda nova feature, refatoração ou bugfix **passa obrigatoriamente** por esse crivo.

---

## 📚 Referência cruzada com demais guias

- 📘 [Guia Master Apex Mamba](https://bit.ly/GuiaApexMamba)
- 🧪 [Guia de Testes Apex](https://bit.ly/GuiaTestsApex)
- 🪵 [Guia de Logger Apex](https://bit.ly/GuiaLoggerApex)
- 🧱 [Guia de Setup de Dados de Teste](https://bit.ly/TestDataSetup)
- 🔁 [Guia de Comparações de Código](https://bit.ly/ComparacaoApex)
- ✅ [Guia de Equivalência Funcional](https://bit.ly/ConfirmacaoApex)

---

## ✅ Fundamentos da Revisão Mamba

- **Rastreabilidade vem antes da performance.**
- **Boilerplate nunca é desperdício quando traz previsibilidade.**
- **Testes que “passam” não significam que cobrem.**
- **O código deve se explicar sozinho – o log, confirmar.**

---

## ✔️ Checklist Mamba para Revisão

### 🔒 Arquitetura & Estrutura
- [ ] Classe possui `@TestVisible`, `className`, `logCategory`, `triggerType`
- [ ] `RecordHelper.getById(...)` aplicado nos `SELECT Id WHERE ...`
- [ ] `FlowExecutionLog__c` presente se for lógica de negócio crítica
- [ ] Nenhum `System.debug()` fora de teste

### 🧪 Testes
- [ ] Possui `@TestSetup` com `TestDataSetup.setupCompleteEnvironment()`
- [ ] `SELECT LIMIT 1` defensivo (sem QueryException)
- [ ] `System.assert(...)` com mensagem real
- [ ] Nenhum uso de `testData.get(...)` dentro dos métodos de teste
- [ ] `fakeIdForSafe(...)` aplicado em cenários de ausência

### 🔁 Refatoração
- [ ] Antes vs Depois disponível ([link](https://bit.ly/ComparacaoApex))
- [ ] Equivalência funcional formalizada ([link](https://bit.ly/ConfirmacaoApex))
- [ ] Fallbacks adicionados em campos `null`, `blank`, `invalid`
- [ ] Métodos que retornam objetos garantem `null-safe` com `RecordHelper` ou `List<T>` + `isEmpty()`

---

## 🚫 Proibições intransigentes

| Item                        | Proibido                      | Alternativa Mamba                           |
|-----------------------------|-------------------------------|----------------------------------------------|
| `System.debug(...)`         | ❌ Fora de testes              | `LoggerContext` ou `FlowExecutionLog__c`     |
| `SELECT ... LIMIT 1` direto| ❌ Sem fallback                | `RecordHelper.getById(...)` ou `List<T>`     |
| `testData.get(...)`        | ❌ Dentro de @IsTest           | Sempre usar `SELECT` após `@TestSetup`       |
| `%` em números             | ❌ `a % b` inválido em Apex    | `Math.mod(a, b)`                             |
| `padLeft/padRight`         | ❌ Não suportado               | `String.format` ou concat manual             |

---

## 🔁 Exemplo de Refatoração Antes vs Depois

### ❌ Antes:
```apex
Account acc = [SELECT Id, Name FROM Account WHERE Id = :id LIMIT 1];
```

### ✅ Depois:
```apex
Account acc = (Account) RecordHelper.getById(Account.SObjectType, id, 'Id, Name');
```

---

## 📌 Exemplo de assertiva mamba:
```apex
System.assertEquals(1, contas.size(), 'Esperado 1 conta. Obtido: ' + contas.size());
```

### ❌ Nunca use:
```apex
System.assert(conta != null);
```
🔁 Use:
```apex
System.assertNotEquals(null, conta, 'Conta retornada foi null');
```

---

## 🧪 Exemplo de teste rastreável com fallback
```apex
List<UC__c> ucs = [SELECT Id FROM UC__c LIMIT 1];
if (ucs.isEmpty()) {
    TestHelper.assertSetupCreated('UC__c');
}
UC__c uc = ucs[0];
```

---

## 🧠 Final

Revisar código não é só aprovar. É confirmar que:
- Rastreia
- Registra
- Funciona em produção
- Passa por testes agressivos

📌 **Nada é considerado revisado sem checklist preenchido.**

🧠🧱🧪 #RevisaoMamba #FiltroDeExcecao #NadaEntraSemValidacao

