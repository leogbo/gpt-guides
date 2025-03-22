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

## **Diretrizes de Testes no Guia Rigoroso**

#### 1. **Evitar Dependência de Variáveis de Mapeamento como `testData`**
A variável `testData`, geralmente usada para armazenar objetos criados em métodos `@TestSetup`, **não deve ser usada para consultar registros em testes**, pois isso pode causar inconsistências se os dados não forem carregados corretamente ou se a estrutura do teste mudar. **A prática recomendada é sempre utilizar consultas `SOQL` diretamente** para garantir que os registros sejam recuperados corretamente do banco de dados.

- **Errado:**
```apex
    @TestSetup
    static void setupTestData() {
        testData = TestDataSetup.setupCompleteEnvironment();
    }

    @IsTest
    static void testMethod() {
        Contact contato = (Contact) testData.get('Contact');
    }
```

- **Correto:**
```apex
    @TestSetup
    static void setupTestData() {
        TestDataSetup.setupCompleteEnvironment();
    }

    @IsTest
    static void testMethod() {
        Contact contato = [SELECT Id, MobilePhone FROM Contact LIMIT 1];
        System.assertNotEquals(null, contato, 'Contato não foi encontrado.');
    }
```

#### 2. **Uso de `SOQL` Direto para Recuperação de Dados**
Sempre que você precisar recuperar registros de objetos no banco de dados durante os testes, **utilize `SOQL` diretamente**. Isso assegura que você esteja consultando dados reais do banco de dados e que o teste tenha maior veracidade e confiabilidade.

- Sempre use `SELECT` diretamente nos testes para garantir que os dados estão sendo carregados de forma precisa.
- Exemplo de uso:
```apex
    @IsTest
    static void testGetCobrancas() {        
        // Consultando diretamente os registros
        Contato_da_UC__c contatoDaUc = [SELECT Id, Contact__c FROM Contato_da_UC__c LIMIT 1];
        Contact contato = [SELECT Id, MobilePhone FROM Contact WHERE Id = :contatoDaUc.Contact__c LIMIT 1];
        
        System.assertNotEquals(null, contatoDaUc, 'Contato da UC não foi encontrado.');
        System.assertNotEquals(null, contato, 'Contato não foi encontrado.');
    }
```

#### 3. **Evitar Uso de `System.debug()` em Testes**
O uso de `System.debug()` é **proibido em testes**, exceto para fins de depuração durante o desenvolvimento. Em vez disso, utilize **logs estruturados** com `LoggerContext.getLogger().log(...)`, que são obrigatórios para todos os testes.

- **Errado:**
```apex
    System.debug('Erro: Contato não encontrado em testData');
```

- **Correto:**
```apex
    LoggerContext.getLogger().log(Logger.LogLevel.ERROR, className, 'testMethod', null, 'Erro: Contato não encontrado.');
```

#### 4. **Desabilitação de Fluxos**
Sempre que necessário, use **`FlowControlManager.disableFlows()`** no método `@TestSetup` para garantir que os fluxos automáticos não sejam acionados durante os testes.

- Exemplo:
```apex
    @TestSetup
    static void setupTestData() {
        TestDataSetup.setupCompleteEnvironment();
        
        // Desabilitando flows para garantir que não sejam acionados durante o teste
        FlowControlManager.disableFlows();
    }
```

#### 5. **Documentação de Casos de Teste**
Cada método de teste deve ter um propósito claro e ser bem documentado, incluindo a descrição do comportamento esperado, cenário de teste, dados de entrada e a verificação dos resultados.

---

### **Objetivos dessa Prática no Guia de Testes:**

1. **Aumentar a Precisão dos Testes:** A utilização de consultas `SOQL` diretamente permite que os testes sejam mais próximos de um cenário real, com dados de banco de dados consistentes.
2. **Facilitar a Manutenção de Testes:** O uso direto de `SOQL` permite que os testes sejam mais claros e menos propensos a falhas relacionadas ao uso inadequado de variáveis temporárias ou não carregadas corretamente.
3. **Seguir as Melhores Práticas de Performance:** Consultas `SOQL` ajudam a garantir que o código do teste seja o mais eficiente possível, evitando problemas de integridade de dados e de performance.

---

### **Exemplo Completo do Guia de Testes:**

```markdown
## **Guia de Testes - Rigoroso**

### **Objetivos dos Testes:**
- Garantir que o código seja executado corretamente com dados reais.
- Testar as interações entre os objetos no banco de dados.
- Garantir que os fluxos e funcionalidades da aplicação sejam mantidos.

### **Boas Práticas de Testes:**

#### **1. Recuperação de Dados com SOQL**
Sempre que for necessário recuperar dados, use consultas `SOQL` diretamente. Não use mapeamentos ou `testData` que possam não ser carregados corretamente.

```apex
    @IsTest
    static void testMethod() {
        Contact contato = [SELECT Id, MobilePhone FROM Contact LIMIT 1];
        System.assertNotEquals(null, contato, 'Contato não foi encontrado.');
    }
```

#### **2. Desabilitação de Fluxos**
Use `FlowControlManager.disableFlows()` para desabilitar fluxos automaticamente durante a execução dos testes, garantindo que fluxos não sejam acionados.

```apex
    @TestSetup
    static void setupTestData() {
        FlowControlManager.disableFlows();
    }
```

#### **3. Logs em vez de System.debug()**
Nunca use `System.debug()` nos testes. Utilize sempre `LoggerContext.getLogger().log(...)` para registrar informações importantes sobre a execução do teste.

```apex
    LoggerContext.getLogger().log(Logger.LogLevel.ERROR, 'ClassName', 'MethodName', null, 'Erro: Mensagem de erro');
```

#### **4. Testes de Erro**
Sempre que testar uma falha, valide a resposta da API e os logs adequados, garantindo que os erros sejam registrados corretamente.

```apex
    System.assert(response.contains('error'), 'Deveria retornar erro no JSON.');
    List<Logger.Log.Entry> logs = ((LoggerMock) LoggerContext.getLogger()).getLogs();
    System.assert(logs.size() > 0, 'O erro deveria estar registrado nos logs.');
```

---
```
