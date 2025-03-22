# 🧪 Guia Rigoroso de Testes Apex

## ✅ Padrão Mínimo Obrigatório

- Todo teste deve:
  - Usar `TestDataSetup.setupCompleteEnvironment()`
  - Desativar flows com `FlowControlManager.disableFlows()` **somente depois**
  - Ativar `LoggerMock` com `LoggerContext.setLogger(new LoggerMock());`

---

## 🧪 Ordem Recomendada

```apex
@TestSetup
static void setupTestData() {
    TestDataSetup.setupCompleteEnvironment();
    FlowControlManager.disableFlows();
}
```

---

## ✅ LoggerMock nos testes

Sempre injetar o mock antes do `Test.startTest()`:

```apex
LoggerContext.setLogger(new LoggerMock());
```

### 🔍 Validação de logs gerados

```apex
List<String> logs = ((LoggerMock) LoggerContext.getLogger()).getLogs();
Boolean logEncontrado = false;
for (String log : logs) {
    if (log.contains('createAccount')) {
        logEncontrado = true;
        break;
    }
}
System.assertEquals(true, logEncontrado, 'Deveria haver log de criação de Account.');
```

---


🚧 Capítulo em construção conforme o **Guia Rigoroso de Testes Apex**.  
Segue abaixo o novo **capítulo dedicado à mockagem de `RestRequest` e `RestResponse`**, com foco total em padronização, clareza e cobertura de cenários esperados e de exceção.

---

# 📦 CAPÍTULO 7 – Mockagem Rigorosa de `RestRequest` e `RestResponse`

---

## 🎯 Objetivo

Este capítulo estabelece o **padrão obrigatório** para criação de testes de métodos `@RestResource`, garantindo:

- Isolamento completo da camada HTTP
- Simulação fiel de cenários **positivos**, **inválidos**, **incompletos** e **malformados**
- Testes funcionais com verificação de logs, exceções e respostas HTTP padronizadas

---

## ✅ 7.1 – Estrutura mínima obrigatória

Todo teste que aciona uma classe `@RestResource` deve conter:

```apex
RestContext.request = new RestRequest();
RestContext.response = new RestResponse();
```

> 🔒 **Proibido omitir `RestContext.response`!**  
> Isso impede `RestServiceHelper.sendResponse(...)` de funcionar e quebra a serialização de saída.

---

## 🧱 7.2 – Padrão base para requisições

### Exemplo: requisição GET com parâmetro de query

```apex
RestContext.request = new RestRequest();
RestContext.response = new RestResponse();

RestContext.request.requestURI = '/services/apexrest/seuendpoint';
RestContext.request.httpMethod = 'GET';
RestContext.request.addParameter('id', 'a00XXXXXXXXXXXX');
RestContext.request.addHeader('Access_token', Label.BEARER_SEU_LABEL);
```

### Exemplo: requisição POST com JSON no body

```apex
Map<String, Object> body = new Map<String, Object>{
    'campo1' => 'valor',
    'campo2' => 123
};
RestContext.request = new RestRequest();
RestContext.response = new RestResponse();

RestContext.request.requestURI = '/services/apexrest/seuendpoint';
RestContext.request.httpMethod = 'POST';
RestContext.request.requestBody = Blob.valueOf(JSON.serialize(body));
RestContext.request.addHeader('Access_token', Label.BEARER_SEU_LABEL);
RestContext.request.addHeader('Content-Type', 'application/json');
```

---

## ⚠️ 7.3 – Cenários obrigatórios de mockagem

### 🔐 A. Token ausente ou inválido

```apex
RestContext.request.addHeader('Access_token', 'Bearer INVALIDO');
```

> Espera-se que `RestServiceHelper.validateAccessToken(...)` lance `AccessException`.

---

### 📭 B. Parâmetro obrigatório ausente

```apex
RestContext.request.addParameter('id', null);
```

> Espera-se resposta 400 com mensagem `"Parâmetro 'id' é obrigatório."` ou exceção personalizada.

---

### 🧨 C. Requisição malformada (ex: JSON inválido)

```apex
RestContext.request.requestBody = Blob.valueOf('{ campo1: valor }'); // JSON inválido
```

> Espera-se que `getRequestBody()` lance `BadRequestException`.

---

### ☁️ D. Sucesso com todos os dados corretos

```apex
// Parâmetros e headers válidos
RestContext.request.addParameter('id', registro.Id);
RestContext.request.addHeader('Access_token', Label.BEARER_XYZ);

// Expectativa: resposta 200 com corpo contendo os dados esperados
```

---

## 🧪 7.4 – Assertivas obrigatórias no teste

```apex
System.assertEquals(expectedStatus, RestContext.response.statusCode, 'Código HTTP inesperado');
System.assert(RestContext.response.responseBody != null, 'Corpo da resposta não pode ser nulo');
```

Quando testando exceções explícitas:

```apex
Boolean lancou = false;
try {
    ClasseREST.metodo();
} catch (RestServiceHelper.AccessException e) {
    lancou = true;
}
System.assert(lancou, 'Exceção de acesso esperado não foi lançada');
```

---

## 💡 7.5 – Dica para parametrizar testes

Crie métodos auxiliares para gerar o `RestRequest` com diferentes cenários. Exemplo:

```apex
private static void mockRequest(String token, String metodo, String uri, String bodyJson) {
    RestContext.request = new RestRequest();
    RestContext.response = new RestResponse();
    RestContext.request.httpMethod = metodo;
    RestContext.request.requestURI = uri;
    if (token != null) RestContext.request.addHeader('Access_token', token);
    if (bodyJson != null) RestContext.request.requestBody = Blob.valueOf(bodyJson);
}
```

---

## 🔒 7.6 – Proibições rígidas

| ❌ Proibido                           | Motivo |
|-------------------------------------|--------|
| Omitir `RestContext.response`       | Impede envio de resposta |
| Enviar body malformado sem assert   | Teste inválido |
| Enviar token correto em cenário negativo | Teste perde propósito |
| Usar `System.debug` sem `LoggerMock` | Fora do padrão rigoroso de logs |

---

📘 Este capítulo será referenciado por todos os testes `@isTest` que envolvam REST, seja GET, POST ou PATCH.

Deseja que eu gere um *template base* reutilizável de mock de `RestRequest` com parâmetros dinâmicos também?

---

## 🎯 Cobertura de testes

- Cenário positivo (sucesso)
- Cenário negativo (erro esperado)
- Cenário de exceção (try/catch validando falha)


---
