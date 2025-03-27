# 🌐 Guia Oficial de APIs REST em Apex (v2025) – Mentalidade Mamba

📎 **Shortlink oficial:** [bit.ly/Guia_APIs_REST](https://bit.ly/Guia_APIs_REST)

> “Toda API carrega a reputação da sua plataforma. Ela deve ser clara, previsível e rastreável.” – Mentalidade Mamba 🧠🔥

Este guia define os **padrões obrigatórios** para criar, testar e versionar APIs REST internas na sua org Salesforce.

---

## 📚 Referências complementares obrigatórias

- 📘 [Guia Master de Arquitetura](https://bit.ly/GuiaApexMamba)
- 🔍 [Guia de Revisão Apex](https://bit.ly/GuiaApexRevisao)
- 🪵 [Guia de Logging](https://bit.ly/GuiaLoggerApex)
- 🧪 [Guia de Testes](https://bit.ly/GuiaTestsApex)
- 🧱 [Guia de TestData Setup](https://bit.ly/TestDataSetup)

---

## ✅ Estrutura de uma classe REST Apex

```apex
@RestResource(urlMapping='/lead/v1')
global with sharing class LeadRestController {

    @HttpPost
    global static RestResponseDTO createLead() {
        try {
            Map<String, Object> payload = RestServiceHelper.getRequestBody();
            Lead newLead = new Lead();
            RestServiceHelper.mapFieldsFromRequest(payload, newLead, 'Lead');
            insert newLead;
            return RestServiceHelper.created('Lead criado com sucesso', newLead);
        } catch (Exception ex) {
            return RestServiceHelper.internalServerError('Erro ao criar Lead', ex);
        }
    }
}
```

---

## 🧩 O que é `RestServiceHelper`?

Classe utilitária padrão com os seguintes propósitos:

- Valida token de autenticação (se aplicado)
- Faz parse seguro do corpo da requisição
- Gera respostas com código HTTP + mensagem padronizada
- Gera logs via `FlowExecutionLog__c`
- Aplica JSON nos campos do objeto com `mapFieldsFromRequest(...)`

> 🧠 Todas APIs REST devem depender desse helper. Nunca crie uma do zero.

---

## ✅ Formato padrão de resposta REST

```json
{
  "success": true,
  "message": "Lead criado com sucesso",
  "data": {
    "Id": "00Q...",
    "Name": "Nome Teste"
  },
  "ref": "trace-id"
}
```

---

## ✅ Métodos de resposta prontos

| Método                          | Status | Uso                                                   |
|----------------------------------|--------|--------------------------------------------------------|
| `ok(data)`                       | 200    | Sucesso com dados                                      |
| `created(msg, data)`            | 201    | Recurso criado com sucesso                            |
| `badRequest(msg)`               | 400    | Erro de validação de entrada                         |
| `unauthorized(msg)`             | 401    | Token ausente ou inválido                             |
| `notFound(msg)`                 | 404    | Recurso não encontrado                                 |
| `internalServerError(msg, ex)`  | 500    | Erro inesperado com log                                |

---

## ❌ Erros comuns a evitar

| Erro                         | Correto                                                   |
|------------------------------|------------------------------------------------------------|
| `JSON.deserializeUntyped()` | ❌ Use `RestServiceHelper.getRequestBody()`                |
| `throw new Exception(...)`  | ❌ Use `return RestServiceHelper.internalServerError(...)` |
| `return 'ok';`              | ❌ Sempre retorne um DTO completo com status               |
| `System.debug(...)`         | ❌ Proibido. Use LoggerContext                             |

---

## 🧪 Testes obrigatórios para APIs REST

- `@IsTest` com `@TestSetup` que cria registros reais (Lead, Account, etc.)
- Mocks para chamadas externas se houver (`HttpCalloutMock`)
- LoggerMock aplicado:
```apex
LoggerContext.overrideLogger(new LoggerMock());
```
- Teste de happy path + bad request + not found

---

## ✅ Checklist de API REST Mamba

| Item                                                        | Status |
|-------------------------------------------------------------|--------|
| Classe REST com `@RestResource(...)`                        | [ ]    |
| Uso exclusivo de `RestServiceHelper`                        | [ ]    |
| Logger aplicado (`LoggerContext` ou `FlowExecutionLog`)     | [ ]    |
| `JSON.serializePretty(...)` para logs                       | [ ]    |
| `@IsTest` com `LoggerMock`                                  | [ ]    |
| Teste com entrada válida e erro de entrada (400)             | [ ]    |
| Nunca usar `System.debug(...)`                              | [ ]    |

---

🧠🧱🧪 #APIMamba #RestComRaiz #RespostasPadronizadas #SemDebugNunca #TraceSemprePresente

