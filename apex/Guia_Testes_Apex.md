# ✅ Guia Rigoroso de Testes Apex

---

## 🧪 Guia Rigoroso de Testes Apex

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
3. Só depois: alterações customizadas e `update`
4. Usar `Test.startTest()` e `Test.stopTest()` em blocos pontuais

> ⚠️ Toda classe de `TestDataSetup` deve usar cache local estático (`if (mock == null)`) para evitar estouro de limites em testes de carga.

---

## 🪵 3. Uso obrigatório de `LoggerMock`

Todo teste que envolva logs estruturados **deve mockar o logger** com:

```apex
LoggerContext.setLogger(new LoggerMock());
```

### ✅ Verificação dos logs gerados:

```apex
List<String> logs = ((LoggerMock) LoggerContext.getLogger()).getLogs();
Boolean encontrou = logs.any(log => log.contains('Contato retornado com sucesso'));
System.assertEquals(true, encontrou, 'Log esperado não foi encontrado.');
```

> ⚠️ **Proibido usar `System.debug()`** fora de testes de baixo nível.

---

# 📦 4. Mockagem Rigorosa de `RestRequest` e `RestResponse`

---

## ✅ 4.1 – Estrutura mínima obrigatória

```apex
RestContext.request = new RestRequest();
RestContext.response = new RestResponse();
```

> 🔒 **Obrigatório simular `RestContext.response`**.  
> Sem isso, chamadas como `res.responseBody = Blob.valueOf(...)` lançam `NullPointerException`.

---

## 🧱 4.2 – Exemplo base `GET`

```apex
RestContext.request = new RestRequest();
RestContext.response = new RestResponse();
RestContext.request.requestURI = '/services/apexrest/minhaapi?id=abc123';
RestContext.request.httpMethod = 'GET';
RestContext.request.addHeader('Access_token', Label.BEARER_EXEMPLO);
```

---

## 📦 4.3 – Exemplo base `POST` com JSON

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

## ⚠️ 4.4 – Cenários obrigatórios

| Cenário                       | Simulação                                         |
|------------------------------|----------------------------------------------------|
| 🔐 Token inválido            | `addHeader('Access_token', 'BearerInvalido')`     |
| 📭 Parâmetro ausente         | `requestURI = '/.../get?id='`                     |
| 🧨 JSON inválido             | `requestBody = Blob.valueOf('{ campo: }')`        |
| ☁️ Sucesso                   | `addParameter('id', contato.Id)` + token válido   |

---

## 🧪 4.5 – Assertivas obrigatórias

### ✅ Resposta esperada

```apex
System.assertEquals(200, RestContext.response.statusCode, 'Status inesperado: ' + RestContext.response.statusCode);
System.assertNotEquals(null, RestContext.response.responseBody, 'Body da resposta está nulo');
```

### 🚨 Em caso de exceções

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

### 🔍 Asserções devem conter o valor real

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

## 🧩 4.6 – Método auxiliar para requisições mockadas

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

## 🚫 4.7 – Sintaxes proibidas

| Proibido                            | Motivo técnico                        |
|------------------------------------|----------------------------------------|
| Omitir `RestContext.response`      | NullPointer em `responseBody`         |
| Usar `System.debug`                | Fora do padrão                        |
| Testar apenas sucesso              | Cobertura incompleta                  |
| Ignorar `LoggerContext.setLogger` | Logs não serão capturados no teste   |

---

# 🧪 5. Testes Obrigatórios de Métodos `@TestVisible`

---

## ✅ Regras obrigatórias

- Todo método `private` com lógica relevante **deve ser `@TestVisible`**
- Deve haver ao menos **1 teste de sucesso** e **1 de falha**
- Exceções lançadas devem ser cobertas

---

## ⚠️ Casos típicos esperados

| Método                  | Cenário positivo       | Cenário negativo       |
|-------------------------|------------------------|------------------------|
| `validateXxx(...)`      | valor válido           | valor nulo/inválido    |
| `buildXxx(...)`         | objeto completo        | objeto vazio/nulo      |
| `logXxx(...)`           | mensagem válida        | mensagem vazia         |

---

## ✅ Exemplo padrão

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

## 📌 6 Testes REST com `RestContext.response` (💥 NPE Prevention)

---

### ✅ Regra crítica

> Se o método REST usa `RestContext.response.responseBody = Blob.valueOf(...)`, **você deve simular `RestContext.response` no teste.**

### 🔥 Sintoma de erro:
```
System.NullPointerException: Attempt to de-reference a null object
```

### ✅ Correto:

```apex
RestContext.request = new RestRequest();
RestContext.response = new RestResponse(); // ← obrigatório!
...
ClasseREST.metodo();
String response = RestContext.response.responseBody.toString();
```

---

## 📎 Referência cruzada:
- [Guia de Logging Apex](https://bit.ly/GuiaLoggerApex)
- [Guia de Revisão Apex](https://bit.ly/GuiaApexRevisao)
- [Guia de Refatoração Apex](https://bit.ly/ComparacaoApex)
- [TestDataSetup Completo](https://bit.ly/TestDataSetup)

---

Se quiser, posso versionar esse conteúdo como Markdown para PR no seu repositório de guias ou entregar `.md` final. Deseja? ✅
