# ************* PENDENCIAS A INTEGRAR **********

💡 Sugestão: Consolidar uma nova seção nos guias
📂 Validação de Entradas e Assertivas em Testes

Onde centralizamos todas as regras que reforçam a importância de:

Validar parâmetros de entrada

Gerar exceções explícitas e previsíveis

Garantir que testes que esperam falha de fato cobrem essa falha

# ************* FIM DAS PENDENCIAS **********


# 🔁 Template Oficial – Comparativo Antes vs Depois da Refatoração

> Use este template obrigatório em todas as entregas de revisão/refatoração para demonstrar **equivalência funcional**, identificar melhorias estruturais e garantir que nada foi perdido no processo.

---

## 📄 Classe revisada

**Nome da classe:** `{{NomeDaClasse}}`  
**Tipo:** Apex Class / Trigger Handler / REST / Batch / Queueable / Test

---

## ✅ Código Revisado (Versão Final)

> Inclua aqui o código refatorado completo, validado pelo [Guia Rigoroso de Revisão Apex](https://bit.ly/GuiaApexRevisao) e pelo [Guia Logger (v2)](https://bit.ly/GuiaLoggerApex)

---

## 🔍 Comparativo Técnico

| Elemento                  | Antes                                      | Depois                                        | Observação Técnica                         | Status |
|---------------------------|---------------------------------------------|-----------------------------------------------|---------------------------------------------|--------|
| 🎯 Nome da classe         | `Cidade_Rest_API`                          | `Cidade_Rest_API`                             | Nome mantido                               | ✅     |
| 🔒 Métodos públicos       | `@InvocableMethod createUC()`             | `createUC()`                                  | Sem alteração                              | ✅     |
| 🔒 Variáveis públicas     | `@InvocableVariable prop_id`              | `prop_id`                                     | Nome mantido                               | ✅     |
| 📦 JSON Input/Output      | `{ prop_id: "123" }`                       | `{ prop_id: "123" }`                          | Estrutura inalterada                       | ✅     |
| 🪵 Logging                | `System.enqueueJob(...)`                   | `Logger.setMethod(...).error(...)`            | Migrado para padrão `Logger (v2)`          | ✅     |
| ⚠️ Tratamento de erro     | Sem `try/catch`                            | Try/Catch com `Logger.error(...)`             | Logging de exceções incluído               | ✅     |
| 🧪 Testes                 | Usava `LoggerMock.getLogs()`               | Usa apenas `LoggerMock` (sem validação direta) | Conforme guia de testes                    | ✅     |
| 🧩 Modularização          | Lógica inline                              | Extraída para `validaToken()`, etc.           | Melhor legibilidade e testabilidade        | ✅     |
| 🧪 Logs validados?        | Sim (com `.getLogs()`)                     | ❌ Removido – log não é validado em teste     | Correção crítica conforme `Logger v2`      | ✅     |

---

## 📋 Checklist Técnico de Equivalência

| Item                                                                 | Confirmado? |
|----------------------------------------------------------------------|-------------|
| 🔒 Nome da classe **não foi alterado**                               | ✅ / ❌      |
| 🔒 Métodos públicos **não foram alterados**                          | ✅ / ❌      |
| 🔒 Campos/variáveis públicas **mantidos**                            | ✅ / ❌      |
| 🔄 JSON de input/output **inalterado**                               | ✅ / ❌      |
| 🧪 Todos os testes anteriores passaram                               | ✅ / ❌      |
| 🧪 Nenhum log foi validado diretamente no teste                      | ✅ / ❌      |
| 🪵 Logging migrou para `Logger` com `.setMethod().error(...)`        | ✅ / ❌      |
| 🐞 `System.debug()` só em classes de teste (se houver)              | ✅ / ❌      |
| 📄 Fluxos anteriores continuam cobertos                              | ✅ / ❌      |

---

## 🧠 Justificativas para alterações (se aplicável)

> Descreva abaixo quaisquer mudanças **além de refatoração estrutural**:

- Inclusão de tratamento de exceção com rastreamento
- Ajuste em cálculo com validação de equivalência
- Extração de método auxiliar com `@TestVisible`
- Atualização de asserts para `.toUpperCase()` ou mensagens explícitas

---

## ✅ Confirmação Final

```markdown
✔️ Refatoração validada como funcionalmente equivalente

- Nenhum método público ou estrutura JSON foi alterado
- Logging atualizado para `Logger (v2)` com contexto fluente e rastreável
- Testes atualizados com `LoggerMock` sem validação direta de log
- Fluxos de exceção cobertos com `Logger.error(...)`
- Toda alteração é estrutural, segura e auditável
```

---

## 📎 Compatibilidade com guias oficiais

- [x] [Guia de Revisão Apex](https://bit.ly/GuiaApexRevisao)
- [x] [Guia de Testes Apex](https://bit.ly/GuiaTestsApex)
- [x] [Guia de Logger Apex (v2)](https://bit.ly/GuiaLoggerApex)
- [x] [Template de Comparação](https://bit.ly/ComparacaoApex)
- [x] [TestDataSetup Central](https://bit.ly/TestDataSetup)
- [x] [Confirmação de Equivalência](https://bit.ly/ConfirmacaoApex)

---

> 🟢 Versão 2025 validada pelo Apex Revisor Rigoroso  
> 📅 Última atualização: MAR/2025

---
