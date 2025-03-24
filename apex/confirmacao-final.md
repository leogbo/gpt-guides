# 📄 Guia de Confirmação de Equivalência Funcional – Apex (Versão Estendida 2025)

> 🌐 Base original: [bit.ly/ConfirmacaoApex](https://bit.ly/ConfirmacaoApex)

📎 Consulte também:
- 📘 [Guia de Revisão Apex](https://bit.ly/GuiaApexRevisao)
- 🧪 [Guia de Testes Apex](https://bit.ly/GuiaTestsApex)
- 🔁 [Template de Comparação Antes vs Depois](https://bit.ly/ComparacaoApex)
- 🧱 [Guia TestDataSetup](https://bit.ly/TestDataSetup)

---

## ✅ Objetivo

Garantir que toda **refatoração preserve integralmente o comportamento funcional anterior**, mesmo com melhorias estruturais, de logging ou extração de métodos.

---

## 📋 Checklist Técnico de Equivalência

| Item                                                                 | Confirmado? |
|----------------------------------------------------------------------|-------------|
| 🔒 Nome da classe **não foi alterado**                               | ✅ / ❌      |
| 🔒 Métodos expostos (públicos/global/@InvocableMethod) **mantidos**  | ✅ / ❌      |
| 🔒 Variáveis expostas (`@InvocableVariable`, parâmetros REST) **inalteradas** | ✅ / ❌ |
| 🔄 JSON de input **manteve estrutura original**                      | ✅ / ❌      |
| 🔄 JSON de output **manteve estrutura original**                     | ✅ / ❌      |
| 🧪 Todos os testes anteriores passaram sem alteração                 | ✅ / ❌      |
| 📄 Refatoração cobre os mesmos fluxos do código anterior             | ✅ / ❌      |

---

## 🔁 Tabela de Comparação – Antes vs Depois

| Comparação            | Versão Anterior                       | Versão Refatorada                     |
|-----------------------|----------------------------------------|----------------------------------------|
| Nome da Classe        | `MinhaClasse`                         | `MinhaClasse`                         |
| Método principal      | `processarLead()`                     | `processarLead()`                     |
| Tipo de log usado     | `System.debug(...)`                   | `LoggerContext.getLogger().log(...)`  |
| Validação de token    | Inline (`if(token != 'xyz')`)         | `validaToken(token)`                  |
| Tratamento de erro    | `System.debug(...)`                   | `LoggerHelper.logError(...)`          |

---

## ✅ Confirmação Final de Equivalência

```markdown
✅ Confirmação de Equivalência Funcional

- Nenhum nome de método público ou classe foi alterado
- Nenhuma variável `@InvocableVariable` ou parâmetro REST foi modificada
- Estrutura de JSON de entrada e saída permanece inalterada
- Testes anteriores passam integralmente
- A nova estrutura cobre todos os fluxos originais

→ Refatoração validada como funcionalmente equivalente.
```

---

## ❌ Não é equivalência se...

| Situação                            | Exigência adicional                      |
|------------------------------------|------------------------------------------|
| Mudou nome de método público       | Autorização expressa do mantenedor       |
| Mudou campo de output JSON         | Exige validação regressiva e aprovação   |
| Mudou estrutura da entrada REST    | Exige versão nova da API ou contrato     |
| Criou novo `@InvocableVariable`    | Deve ser aprovado com documentação       |

---

## 📎 Apêndice: O que PODE ser alterado sem quebra

| Pode alterar...                | Desde que...                           |
|-------------------------------|----------------------------------------|
| Métodos `private` ou `@TestVisible` | Permaneçam com lógica equivalente        |
| Logs (`System.debug` → Logger) | Mensagem e nível semântico sejam mantidos |
| Extração de método privado     | A nova função seja logicamente idêntica  |
| Nomes de variáveis internas    | Sem impacto em inputs/outputs externos   |

---

## 🧪 Exemplo completo de aplicação em PR

```markdown
### Refatoração: `Cidade_Rest_API.cls`

- `System.enqueueJob(...)` substituído por `LoggerContext.getLogger().log(...)`
- Método `valida_token()` extraído para clareza
- Bloco de erro `401` mantido idêntico
- Mensagens de log foram mantidas com mesmo significado

✅ Confirmado:
- Nenhum método ou classe teve o nome alterado
- `@InvocableVariable` e JSON de resposta mantiveram estrutura
- Todos os testes passaram sem ajustes

✔️ Refatoração validada como funcionalmente equivalente.
```

---

> 🛡️ Este documento é **obrigatório** para toda refatoração com PR.  
> 📎 Versão 2025 – validada pelo Apex Revisor Rigoroso.

---

Se quiser, posso gerar este conteúdo como arquivo `.md` pronto para uso. Deseja que eu faça isso agora?
