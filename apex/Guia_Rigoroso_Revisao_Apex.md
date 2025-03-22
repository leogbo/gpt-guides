## ✅ Guia Rigoroso de Revisão Apex (Versão Atualizada)

```markdown
# ✅ Guia Rigoroso de Revisão Apex

Última atualização: MAR/2025

---

## 📌 Princípios Fundamentais

1. **Cada classe deve ter uma única responsabilidade (SRP)**
2. **Todos os logs devem usar `LoggerContext.getLogger().log(...)` com 11 parâmetros**
3. **Testes devem usar `LoggerMock` + `TestDataSetup.setupCompleteEnvironment()`**
4. **`System.debug()` é terminantemente proibido**
5. **Uso obrigatório de `LoggerHelper` para padronizar logs**

---

## 🧱 Estrutura obrigatória de classes

Cada classe deve conter no topo:

```apex
public static final String environment = 'test';
public static final Logger.LogLevel log_level = Logger.LogLevel.DEBUG;
public static final String className = '<NOME_DA_CLASSE>';
public static final String triggerType = '<Batch | Trigger | Apex>';
public static final String logCategory = '<domínio funcional>';
```

---

## 📝 Logging padronizado

Use **somente** a interface `ILogger` com todos os **11 parâmetros obrigatórios**:

```apex
LoggerContext.getLogger().log(
    Logger.LogLevel.INFO,
    LoggerContext.className,
    'nomeDoMetodo',
    null,
    'mensagem de erro',
    'debug info',
    'stacktrace',
    null,
    LoggerContext.triggerType,
    LoggerContext.logCategory,
    LoggerContext.environment
);
```

Use `LoggerHelper.logInfo(...)` e `logError(...)` sempre que possível nos módulos de teste.

---

## 🧪 Testes rigorosos

- Testes devem usar:

```apex
LoggerContext.setLogger(new LoggerMock());
```

- E validar logs com:

```apex
List<String> logs = ((LoggerMock) LoggerContext.getLogger()).getLogs();
System.assert(logs.anyMatch(l => l.contains('createAccount')));
```

- Ou com loop:

```apex
Boolean encontrou = false;
for (String log : logs) {
    if (log.contains('createUC')) {
        encontrou = true;
        break;
    }
}
System.assertEquals(true, encontrou);
```

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

---

Excelente diretriz! 📘 Vamos oficializar isso como mais um capítulo do **Guia Rigoroso de Testes Apex**, com o título:

---

# 🧩 CAPÍTULO 8 – Cobertura Obrigatória de Métodos `@TestVisible` Privados

---

## 🎯 Objetivo

Garantir cobertura total, previsibilidade e segurança dos **métodos auxiliares internos** (`private static`) das classes `@RestResource`, `@future`, `Queueable`, triggers e services, especialmente quando:

- Recebem parâmetros primitivos (String, Id, Boolean, etc.)
- Contêm lógica de validação ou formatação
- Influenciam diretamente os fluxos REST ou de negócio

---

## ✅ Regra obrigatória

> Todo método `private` deve ser anotado com `@TestVisible` **e testado diretamente nos testes de unidade da classe**.

---

## 🧪 Benefícios esperados

- ✅ Aumenta a cobertura de linhas e branches
- ✅ Valida comportamentos isolados (ex: `null`, vazio, inválido)
- ✅ Impede que métodos de apoio virem “caixas pretas” não verificadas

---

## 📌 Padrão de testes para métodos auxiliares

Abaixo, os **testes complementares obrigatórios** para a classe `Cobranca_Rest_API_GET.cls`:

---

### ✅ Teste: `validateRecordId`

```apex
@IsTest
static void validateRecordIdTest() {
    Boolean exceptionThrown = false;
    try {
        Cobranca_Rest_API_GET.validateRecordId(null);
    } catch (AuraHandledException ex) {
        exceptionThrown = true;
        System.assert(ex.getMessage().contains('Parâmetro ID inválido.'));
    }
    System.assertEquals(true, exceptionThrown, 'Deveria lançar exceção para ID nulo.');
}
```

---

### ✅ Teste: `validateCobrancaExists`

```apex
@IsTest
static void validateCobrancaExistsTest() {
    Boolean exceptionThrown = false;
    try {
        Cobranca_Rest_API_GET.validateCobrancaExists(null, 'abc123');
    } catch (AuraHandledException ex) {
        exceptionThrown = true;
        System.assert(ex.getMessage().contains('Cobrança não encontrada.'));
    }
    System.assertEquals(true, exceptionThrown, 'Deveria lançar exceção para cobrança nula.');
}
```

---

### ✅ Teste: `getCobrancaById`

```apex
@IsTest
static void getCobrancaByIdTest() {
    setupTestData();
    Cobranca__c result = Cobranca_Rest_API_GET.getCobrancaById(validCobrancaId);
    System.assertNotEquals(null, result, 'Cobrança esperada não encontrada.');
}
```

---

### ✅ Teste: `buildCobrancaResponse`

```apex
@IsTest
static void buildCobrancaResponseTest() {
    setupTestData();
    Cobranca__c cobranca = (Cobranca__c) testData.get('Cobranca');
    Map<String, Object> json = Cobranca_Rest_API_GET.buildCobrancaResponse(cobranca);
    System.assert(json.containsKey('id'), 'JSON deve conter o campo id');
    System.assert(json.containsKey('status'), 'JSON deve conter o campo status');
}
```

---

### ✅ Teste: `addJsonField`

```apex
@IsTest
static void addJsonFieldTest() {
    Map<String, Object> json = new Map<String, Object>();
    Cobranca_Rest_API_GET.addJsonField(json, 'chave', 'valor');
    System.assertEquals('valor', json.get('chave'), 'Valor não foi adicionado corretamente.');

    Cobranca_Rest_API_GET.addJsonField(json, 'nulo', null);
    System.assert(!json.containsKey('nulo'), 'Campos nulos não devem ser adicionados.');
}
```

---

### ✅ Teste: `truncateString`

```apex
@IsTest
static void truncateStringTest() {
    String curta = 'abc';
    String longa = 'x'.repeat(500);

    System.assertEquals(curta, Cobranca_Rest_API_GET.truncateString(curta, 10));
    System.assertEquals(255, Cobranca_Rest_API_GET.truncateString(longa, 255).length());
    System.assertEquals(null, Cobranca_Rest_API_GET.truncateString('', 50));
}
```

---

## 🔒 Observações finais

- **Nunca** remover `@TestVisible` de métodos auxiliares que fazem validações, montagens ou chamadas críticas
- Cada método privado deve ter **pelo menos 1 cenário positivo e 1 de exceção testado**
- A padronização desses testes deve ser obrigatória para **merge de qualquer classe Apex crítica**

---

## 🧱 Arquitetura de dados de teste

### 🔹 Orquestradora principal:
```apex
TestDataSetup.setupCompleteEnvironment()
```

Essa classe **não deve conter nenhuma lógica de criação**, apenas chamar:

### 🔸 Módulos `*TestDataSetup.cls` por objeto:

| Classe                        | Responsável por criar           |
|------------------------------|---------------------------------|
| `UserTestDataSetup`          | `User`, `ProfileId`             |
| `AccountTestDataSetup`       | `Account`, `Contact`            |
| `LeadTestDataSetup`          | Todos os tipos de `Lead`        |
| `DistribuidoraTestDataSetup` | `Distribuidora__c`, `Tarifa__c` |
| `GeradorTestDataSetup`       | `Gerador__c`, `Veiculo__c`, `Produto__c` |
| `VerticalTestDataSetup`      | `Vertical__c`                   |
| `OriginadorTestDataSetup`    | `Originador__c`, filho ou pai   |
| `OpportunityTestDataSetup`   | `Opportunity`                   |
| `PropostaTestDataSetup`      | `Proposta__c`                   |
| `UcTestDataSetup`            | `UC__c`, `Contrato_de_Adesao__c`|
| `CobrancaTestDataSetup`      | `Cobranca__c`                   |
| `DocumentoTestDataSetup`     | Todos os `Documento__*__c`      |
| `SignatarioTestDataSetup`    | `Signatario_do_Gerador__c`, `Signatario_da_Oportunidade__c` |
| `CaseTestDataSetup`          | `Case`                          |

---

## 🚫 Proibições absolutas

| Sintaxe / prática                 | Status      |
|----------------------------------|-------------|
| `System.debug(...)`              | ❌ PROIBIDO |
| `LoggerContext.getLogger().log(...)` com menos de 11 parâmetros | ❌ PROIBIDO |
| `TestDataSetup` contendo lógica de criação | ❌ PROIBIDO |
| Misturar objetos em `*TestDataSetup.cls` (ex: `Lead` em `AccountTestDataSetup`) | ❌ PROIBIDO |
| Safe navigation `obj?.field`     | ❌ Apex não suporta |
| Operadores `??` e `?:`           | ❌ Apex não suporta |
| `var` como tipo de variável      | ❌ Apex exige tipo explícito |

---

## 🧾 Checklist de revisão

- [ ] Cada classe `*TestDataSetup` contém apenas 1 objeto
- [ ] Logging 100% via `LoggerHelper` ou `ILogger` completo
- [ ] Testes usam `LoggerMock` com `LoggerContext.setLogger(...)`
- [ ] Nenhum `System.debug()` existe no código fora de `LoggerMock`
- [ ] `TestDataSetup` só orquestra, não cria registros diretamente

---

✅ **Esse guia é obrigatório para todo PR com testes unitários, batchs, triggers, flows e agendamentos.**
```

---
