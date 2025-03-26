# ************* PENDENCIAS A INTEGRAR **********

💡 Sugestão: Consolidar uma nova seção nos guias
📂 Validação de Entradas e Assertivas em Testes

Onde centralizamos todas as regras que reforçam a importância de:

Validar parâmetros de entrada

Gerar exceções explícitas e previsíveis

Garantir que testes que esperam falha de fato cobrem essa falha

---

🆕 Adicionar verificação:

 Testes não usam testData.get(...) fora de @TestSetup

 Todos os objetos usados após setup são recuperados via SELECT

 ---

### ✅ Uso de SELECT após @TestSetup

Sempre que utilizar `@TestSetup`, acesse os dados criados com `SELECT` explícito.  
Jamais reutilize `Map<String, SObject>` do `setupTestData()` dentro dos métodos `@isTest`.

#### ❌ Errado:
```apex
Vertical__c vertical = (Vertical__c) testData.get('Vertical'); // ← Nulo em tempo de execução
#### ✅ Correto:
Vertical__c vertical = [SELECT Id FROM Vertical__c LIMIT 1];

 ---

# ************* FIM DAS PENDENCIAS **********

# ✅ Confirmação de Equivalência Funcional – Apex Rigoroso v2025

> _Checklist obrigatório para validação de refatorações em classes Apex críticas, com foco em integridade estrutural, contratual e comportamental._

📎 Guias relacionados:
- https://bit.ly/GuiaApexRevisao
- https://bit.ly/GuiaLoggerApex
- https://bit.ly/Guia_APIs_REST
- https://bit.ly/GuiaTestsApex
- https://bit.ly/TestDataSetup
- https://bit.ly/ComparacaoApex
- https://bit.ly/ConfirmacaoApex


---

## 🎯 Objetivo

Garantir que uma refatoração **preserva exatamente o comportamento anterior**, sem quebrar:
- 🔒 Contratos públicos (`public`, `global`, `@Invocable`, JSON)
- 🔁 Fluxos de entrada/saída (REST, Flow, Trigger)
- 🧪 Comportamento em teste
- 🪵 Logging e tratamento de exceções

---

## 📋 Checklist Oficial de Confirmação

| Item                                                                 | Status (✅ / ❌) |
|----------------------------------------------------------------------|------------------|
| 🔒 Nome da classe permaneceu inalterado                              |                  |
| 🔒 Assinaturas de métodos públicos foram mantidas                    |                  |
| 🔒 Variáveis públicas (`@InvocableVariable`, `public`, etc.) mantidas |                  |
| 🔄 JSON de entrada inalterado (ex: REST/Flow)                        |                  |
| 🔄 JSON de saída inalterado                                          |                  |
| 🧪 Todos os testes anteriores continuam passando                     |                  |
| 🧪 Nenhum teste foi excluído ou desativado                           |                  |
| 🧪 Cobertura completa dos novos fluxos adicionados                   |                  |
| 🧪 Testes seguem `TestDataSetup` e usam `LoggerMock`                 |                  |
| 🪵 Logging atualizado para padrão `Logger v2` (com `.setMethod()`)   |                  |
| ⚠️ Exceções agora são logadas corretamente                          |                  |
| 🧱 Refatoração modularizou lógica (ex: `@TestVisible` onde aplicável)|                  |
| 🔐 Segurança e controle transacional foram mantidos                  |                  |

---

## 🧠 Exemplos de validação

- Refatorou `createUC()` sem alterar seu contrato JSON
- Substituiu `System.enqueueJob()` por `Logger.setAsync(true)`
- Moveu lógica inline para `validaCamposObrigatorios() @TestVisible`
- Atualizou testes para usar `LoggerMock`, sem validar insert real
- Confirmou que `Flow` continua chamando a classe via Apex Action

---

## 📦 Evidências incluídas neste PR

- [x] Código final da refatoração
- [x] Template Comparativo Antes vs Depois preenchido
- [x] Testes atualizados com `LoggerMock`
- [x] Confirmação assinada abaixo

---

## ✅ Declaração Final de Equivalência

```markdown
✔️ CONFIRMAÇÃO DE EQUIVALÊNCIA FUNCIONAL

- Esta refatoração **não altera nenhum contrato público**
- Toda entrada e saída JSON foi mantida
- Todos os testes existentes foram preservados e continuam passando
- Novos fluxos de exceção/log foram cobertos com `Logger (v2)`
- Nenhuma regressão funcional foi introduzida
- A refatoração é **estrutural, segura e auditável**

Aprovado para merge.
```

---

## 🧠 Dica Mamba

> Se você **não pode garantir 100% de equivalência**, esta não é uma refatoração — é uma evolução funcional, e precisa ser tratada com mais testes, mais evidências e revisão mais profunda.

---

📅 Última validação: MAR/2025  
🔒 Versão mantida por Apex Revisor Rigoroso
