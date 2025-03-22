Perfeito! Abaixo está o **Guia Rigoroso de Testes Apex** totalmente revisado, atualizado e expandido para refletir o uso de `Logger.LogEntry` e `LoggerMock` estruturado.

Inclui:

- 🪵 Logging com `LoggerMock` estruturado (`LogEntry`)
- 🧪 Validação correta com tipo forte
- ⚠️ Alertas para erros comuns (ex: `Variable does not exist: LogLevel`)
- 🚫 Proibições explícitas
- 📚 Exemplos prontos para uso e refatoração segura

---

```markdown
# ✅ Guia Rigoroso de Testes Apex

---

## 🧪 Objetivo

Este guia define o padrão obrigatório de construção de testes Apex com base em:

- `TestDataSetup` completo
- Desativação de flows (`FlowControlManager`)
- Uso de `LoggerContext.getLogger()` com `LoggerMock`
- Mock de callouts e logs
- Validação de logs com `Logger.LogEntry`

---

## ✅ 1. Estrutura Mínima Obrigatória

Todo teste **deve conter obrigatoriamente**:

```apex
@TestSetup
static void setupTestData() {
    TestDataSetup.setupCompleteEnvironment();
    FlowControlManager.disableFlows();
}
```

E sempre que houver logging estruturado:

```apex
LoggerContext.setLogger(new LoggerMock());
```

---

## 📐 2. Ordem Recomendada no Setup

Padrão de otimização para testes intensivos:

1. `TestDataSetup.setupCompleteEnvironment()`
2. `FlowControlManager.disableFlows()`
3. Depois disso: alterações customizadas (`insert`, `update`, etc.)
4. Usar `Test.startTest()` e `Test.stopTest()` em blocos pontuais

> ⚠️ Toda classe de `TestDataSetup` deve usar cache local estático (`if (mock == null)`) para evitar estouro de limites em testes de carga.

---

## 🪵 3. Uso obrigatório de `LoggerMock`

### ✅ 3.1 – Mock obrigatório

Todo teste que envolva logging estruturado **deve mockar o logger** com:

```apex
LoggerMock logger = new LoggerMock();
LoggerContext.setLogger(logger);
```

---

### ✅ 3.2 – Validação com `Logger.LogEntry`

```apex
List<Logger.LogEntry> logs = logger.getLogs();
System.assertEquals(1, logs.size());
System.assertEquals(Logger.LogLevel.ERROR, logs[0].level);
System.assert(logs[0].errorMessage.contains('Erro ao exportar relatórios'));
```

---

### ⚠️ 3.3 – Erros comuns evitáveis

| Erro                                        | Causa                             | Correção                          |
|--------------------------------------------|-----------------------------------|------------------------------------|
| `Variable does not exist: LogLevel`        | Usou `LogLevel.ERROR` direto      | Use `Logger.LogLevel.ERROR`       |
| `Logger.LogEntry` não compila              | Classe não é `public`             | Torne `public class LogEntry`     |
| `getLogs()` retorna `String`               | `LoggerMock` não foi atualizado   | Implemente `List<Logger.LogEntry>`|

---

### 🚫 3.4 – Sintaxes proibidas

| Proibido            | Motivo                               |
|---------------------|---------------------------------------|
| `System.debug(...)` | Logs não são validados em testes      |
| `System.enqueueJob` | Proibido em produção e testes         |

---

## 📦 4. Mockagem Rigorosa de `RestRequest` e `RestResponse`

---

### ✅ 4.1 – Estrutura mínima obrigatória

```apex
RestContext.request = new RestRequest();
RestContext.response = new RestResponse();
```

> 🔒 **Obrigatório simular `RestContext.response`**.  
> Sem isso, chamadas como `res.responseBody = Blob.valueOf(...)` lançam `NullPointerException`.

---

### 🧱 4.2 – Exemplo base `GET`

```apex
RestContext.request = new RestRequest();
RestContext.response = new RestResponse();
RestContext.request.requestURI = '/services/apexrest/minhaapi?id=abc123';
RestContext.request.httpMethod = 'GET';
RestContext.request.addHeader('Access_token', Label.BEARER_EXEMPLO);
```

---

### 📦 4.3 – Exemplo base `POST` com JSON

```apex
Map<String, Object> payload = new Map<String, Object>{ 'campo' => 'valor' };

RestContext.request = new RestRequest();
RestContext.response = new RestResponse();
RestContext.request.httpMethod = 'POST';
RestContext.request.requestURI = '/services/apexrest/minhaapi';
RestContext.request.requestBody = Blob.valueOf(JSON.serialize(payload));
RestContext.request.addHeader('Access_token', Label.BEARER_EXEMPLO);
RestContext.request.addHeader('Content-Type', 'application/json');
```

---

### ⚠️ 4.4 – Cenários obrigatórios

| Cenário                       | Simulação                                         |
|------------------------------|----------------------------------------------------|
| 🔐 Token inválido            | `addHeader('Access_token', 'BearerInvalido')`     |
| 📭 Parâmetro ausente         | `requestURI = '/.../get?id='`                     |
| 🧨 JSON inválido             | `requestBody = Blob.valueOf('{ campo: }')`        |
| ☁️ Sucesso                   | `addParameter('id', contato.Id)` + token válido   |

---

### 🧪 4.5 – Assertivas obrigatórias

#### ✅ Resposta esperada

```apex
System.assertEquals(200, RestContext.response.statusCode, 'Status inesperado: ' + RestContext.response.statusCode);
System.assertNotEquals(null, RestContext.response.responseBody, 'Body da resposta está nulo');
```

#### 🚨 Em caso de exceções

```apex
Boolean erro = false;
try {
    MinhaClasseREST.metodo();
} catch (MinhaExcecao e) {
    erro = true;
}
System.assertEquals(true, erro, 'Exceção esperada não foi lançada');
```

---

### 🔍 4.6 – Assertivas com valor real

**✅ Correto:**

```apex
System.assertEquals('joao', contato.FirstName.toLowerCase(), 'Nome incorreto: ' + contato.FirstName);
System.assert(response.contains('erro'), 'Resposta: ' + response);
```

**❌ Incorreto:**

```apex
System.assertEquals('joao', contato.FirstName.toLowerCase());
System.assert(response.contains('erro'));
```

---

### 🧩 4.7 – Método auxiliar para requisições mockadas

```apex
private static void mockRequest(String metodo, String uri, String token, String json) {
    RestContext.request = new RestRequest();
    RestContext.response = new RestResponse();
    RestContext.request.httpMethod = metodo;
    RestContext.request.requestURI = uri;
    if (token != null) RestContext.request.addHeader('Access_token', token);
    if (json != null) RestContext.request.requestBody = Blob.valueOf(json);
}
```

---

### 🚫 4.8 – Sintaxes proibidas

| Proibido                            | Motivo técnico                        |
|------------------------------------|----------------------------------------|
| Omitir `RestContext.response`      | NullPointer em `responseBody`         |
| Usar `System.debug`                | Fora do padrão                        |
| Testar apenas sucesso              | Cobertura incompleta                  |
| Ignorar `LoggerContext.setLogger` | Logs não serão capturados no teste   |

---

## 🧪 5. Testes Obrigatórios de Métodos `@TestVisible`

---

### ✅ Regras obrigatórias

- Todo método `private` com lógica relevante **deve ser `@TestVisible`**
- Deve haver ao menos **1 teste de sucesso** e **1 de falha**
- Exceções lançadas devem ser cobertas

---

### ⚠️ Casos típicos esperados

| Método                  | Cenário positivo       | Cenário negativo       |
|-------------------------|------------------------|------------------------|
| `validateXxx(...)`      | valor válido           | valor nulo/inválido    |
| `buildXxx(...)`         | objeto completo        | objeto vazio/nulo      |
| `logXxx(...)`           | mensagem válida        | mensagem vazia         |

---

### ✅ Exemplo padrão

```apex
@IsTest
static void validateIdTest() {
    Boolean erro = false;
    try {
        Classe.validateId(null);
    } catch (Exception e) {
        erro = true;
    }
    System.assertEquals(true, erro, 'Deveria lançar exceção para ID nulo');
}
```

> ⚠️ Cuidado com `AuraHandledException`, que pode ocultar a `getMessage()` em tempo de execução de teste.

---

## 📎 Referência cruzada

- 📘 [Guia de Logging Apex](https://bit.ly/GuiaLoggerApex)
- 🧼 [Guia de Revisão Apex](https://bit.ly/GuiaApexRevisao)
- 🔁 [Guia de Refatoração Apex (Antes vs Depois)](https://bit.ly/ComparacaoApex)
- 🧪 [TestDataSetup Oficial](https://bit.ly/TestDataSetup)

