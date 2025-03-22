# ✅ Guia Rigoroso de Revisão Apex  
📅 Última atualização: MAR/2025

---

## 📌 1. Princípios Fundamentais

1. **Cada classe deve ter uma única responsabilidade (SRP)**
2. **Todos os logs devem usar `LoggerContext.getLogger().log(...)` com 11 parâmetros**
3. **Testes devem usar `LoggerMock` + `TestDataSetup.setupCompleteEnvironment()`**
4. **`System.debug()` é terminantemente proibido**
5. **Uso obrigatório de `LoggerHelper` ou `LoggerContext.getLogger()`**
6. **Métodos `private` relevantes devem ser `@TestVisible` e cobertos por testes**

---

## 🧱 2. Estrutura obrigatória das classes Apex

Topo de toda classe principal deve conter:

```apex
public static final String environment = 'test';
public static final Logger.LogLevel log_level = Logger.LogLevel.DEBUG;
public static final String className = '<NOME_DA_CLASSE>';
public static final String triggerType = '<Batch | Trigger | Apex>';
public static final String logCategory = '<domínio funcional>';
```

---

## 🪵 3. Logging Padronizado

Usar exclusivamente `LoggerContext.getLogger().log(...)` com **todos os 11 parâmetros obrigatórios**:

```apex
LoggerContext.getLogger().log(
    Logger.LogLevel.INFO,
    LoggerContext.className,
    'nomeDoMetodo',
    null,
    'mensagem',
    'detalhes',
    'stacktrace',
    null,
    LoggerContext.triggerType,
    LoggerContext.logCategory,
    LoggerContext.environment
);
```

### ✅ Alternativas para testes e classes auxiliares:

```apex
LoggerHelper.logInfo('msg', 'class', 'method', 'categoria');
LoggerHelper.logError('msg', 'class', 'method', ex, 'categoria');
```

---

# 🧪 4. Testes Rigorosos

---

## ✅ 4.1 Estrutura mínima obrigatória

```apex
@TestSetup
static void setupTestData() {
    TestDataSetup.setupCompleteEnvironment();
    FlowControlManager.disableFlows();
}
```

---

## 🧱 4.2 Logger obrigatório

```apex
LoggerContext.setLogger(new LoggerMock());
```

Validação de logs:

```apex
List<String> logs = ((LoggerMock) LoggerContext.getLogger()).getLogs();
Boolean encontrou = logs.any(l => l.contains('createAccount'));
System.assertEquals(true, encontrou);
```

---

## 📦 4.3 Mockagem de `RestRequest` e `RestResponse`

### ⚠️ Requisito obrigatório

```apex
RestContext.request = new RestRequest();
RestContext.response = new RestResponse(); // 🚨 Nunca omitir!
```

> ❗ Omitir `RestContext.response` causa `NullPointerException` nos métodos `sendResponse(...)`

### ✅ Exemplos:

#### GET com parâmetro
```apex
RestContext.request = new RestRequest();
RestContext.response = new RestResponse();
RestContext.request.requestURI = '/services/apexrest/getinfo';
RestContext.request.httpMethod = 'GET';
RestContext.request.addParameter('id', 'a00...');
RestContext.request.addHeader('Access_token', 'Bearer VALIDO');
```

#### POST com body JSON
```apex
RestContext.request = new RestRequest();
RestContext.response = new RestResponse();
RestContext.request.httpMethod = 'POST';
RestContext.request.requestURI = '/services/apexrest/postinfo';
RestContext.request.requestBody = Blob.valueOf(JSON.serialize(payload));
RestContext.request.addHeader('Access_token', 'Bearer VALIDO');
RestContext.request.addHeader('Content-Type', 'application/json');
```

---

## ⚙️ 4.4 Cenários obrigatórios

| Cenário                        | Esperado                                 |
|-------------------------------|------------------------------------------|
| Token ausente/errado          | `AccessException`                        |
| Parâmetro obrigatório ausente | `badRequest(...)`                        |
| JSON malformado               | `BadRequestException`                    |
| Requisição válida             | Código 200 + `RestContext.responseBody` |

---

## 🧪 4.5 Assertivas esperadas

```apex
System.assertEquals(200, RestContext.response.statusCode);
System.assert(RestContext.response.responseBody != null);
```

Com exceção esperada:

```apex
Boolean erro = false;
try {
    ClasseREST.metodo();
} catch (RestServiceHelper.AccessException e) {
    erro = true;
}
System.assert(erro);
```

---

# 🧩 5. Cobertura Obrigatória de Métodos `@TestVisible`

---

## 🎯 Regra Absoluta

> Todo método `private` com lógica de negócio, validação ou montagem de objetos **deve ser `@TestVisible` e ter teste direto**.

---

## ✅ O que testar

| Tipo de método    | Teste positivo | Teste negativo |
|-------------------|----------------|----------------|
| `validateXxx()`   | Com valor      | Nulo/inválido  |
| `buildXxx()`      | Objeto completo| Objeto parcial |
| `truncateString()`| Curta/longa    | Vazia/nula     |

---

### ✅ Exemplo de `validateRecordId`

```apex
RestContext.request = new RestRequest();
RestContext.response = new RestResponse();

Boolean erro = false;
try {
    MinhaClasse.validateRecordId(null);
} catch (AuraHandledException e) {
    erro = true;
}
System.assertEquals(true, erro);
```

---

# 📘 6. Estrutura Modular de Dados de Teste

---

## 🔹 Setup principal:

```apex
TestDataSetup.setupCompleteEnvironment();
```

## 🔸 Cada módulo cria **somente seu objeto**:

| Classe                        | Responsável por criar           |
|------------------------------|---------------------------------|
| `UserTestDataSetup`          | `User`, `ProfileId`             |
| `LeadTestDataSetup`          | Tipos de `Lead`                 |
| `PropostaTestDataSetup`      | `Proposta__c`                   |
| `CobrancaTestDataSetup`      | `Cobranca__c`                   |
| `GeradorTestDataSetup`       | `Gerador__c`, `Produto__c`      |

---

# 🚫 7. Proibições Invioláveis

| Proibido                         | Motivo |
|----------------------------------|--------|
| `System.debug()`                 | Não rastreável/logável         |
| `enqueueJob(...)` direto         | Use `LoggerContext.getLogger()`|
| `Logger.log(...)` com menos de 11 parâmetros | Quebra padrão de log |
| `TestDataSetup` com lógica de criação | Separação por classe obrigatória |
| Mistura de objetos em *TestDataSetup.cls* | Viola SRP               |
| `var`, `??`, `?.`, `anyMatch()`  | **Não suportados em Apex!**   |

---

# 🧾 8. Checklist de Revisão Final

- [ ] Classe segue estrutura com `environment`, `log_level`, etc.
- [ ] Todos os logs usam `LoggerContext.getLogger().log(...)`
- [ ] Nenhum `System.debug()` no código
- [ ] Testes usam `LoggerMock` e `TestDataSetup`
- [ ] Métodos `@TestVisible` possuem testes diretos
- [ ] `RestContext.response` sempre mockado quando necessário
- [ ] PR cobre cenários de sucesso, exceção e entrada inválida
- [ ] 100% compatível com [Guia de Testes Apex](https://bit.ly/GuiaTestsApex)
