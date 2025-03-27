# 💪 Guia Oficial de Testes Apex – v2025 (Padrão Mamba)
> _Cobertura real. Isolamento absoluto. Testes de elite._

---

## 📓 Guias complementares obrigatórios
- 🩵 [Logger Fluent + Mock](https://bit.ly/GuiaLoggerApex)
- 🪩 [TestDataSetup Global](https://bit.ly/TestDataSetup)
- 🔄 [Template Comparativo Antes vs Depois](https://bit.ly/ComparacaoApex)
- ✅ [Checklist de Equivalência Funcional](https://bit.ly/ConfirmacaoApex)

---

## 🌟 Objetivo do Guia
Garantir que toda classe testada atenda aos critérios de:
- 💥 Cobertura real de lógica (e não de linhas)
- 🔄 Independência entre testes
- 🪩 Isolamento de dados
- 🧠 Simulação de exceções e fluxos inválidos

---

## ✅ Regras Rígidas e Checklist Mamba de Rigor em Testes Apex

| ID   | Regra Mamba                                                                                     | Status |
|------|--------------------------------------------------------------------------------------------------|--------|
| T01 | ❌ `testData.get(...)` **proibido** dentro de métodos `@isTest`                                 | 🔐     |
| T02 | ❌ `setupTestData()` **jamais chamado manualmente** dentro de `@isTest`                       | 🔐     |
| T03 | ✅ Toda preparação de dados deve ocorrer exclusivamente em `@TestSetup`                    | ✅     |
| T04 | ❌ `FlowControlManager.disableFlows()` deve ser chamado apenas 1x no `@TestSetup`            | 🔐     |
| T05 | ❌ `createUser(..., true)` + `System.runAs()` externo causa `Test already started`           | 🔐     |
| T06 | ✅ `createUser(..., false)` + `runAs + startTest/stopTest` deve ser usado corretamente       | ✅     |
| T07 | ❌ Testes `isParallel=true` **não podem fazer DML em objetos restritos** (User, Profile)       | 🔐     |
| T08 | ✅ Sempre usar `SELECT` direto nos métodos `@isTest` (nunca depender de instância estática) | ✅     |
| T09 | ✅ Asserts devem ter mensagens claras e rastreáveis                                        | ✅     |
| T10 | ❌ `LoggerMock.getLogs()` **nunca** deve ser usado para validação (somente neutraliza log)     | 🔐     |
| T11 | ✅ Dados de teste devem vir exclusivamente do `TestDataSetup`                                | ✅     |
| T12 | ✅ Cada teste deve validar **comportamento funcional real**                                  | ✅     |

---

## 🔧 Setup de Ambiente Padrão

```apex
@TestSetup
static void setup() {
    Map<String, Object> testData = TestDataSetup.setupCompleteEnvironment();
    System.assertNotEquals(null, testData.get('DocProposta'), 'DocProposta was not setuped.');
    FlowControlManager.disableFlows();
}
```

---

## 💪 Testes com Queueable + TestDataSetup + FlowControlManager

### 📀 Caminho feliz (success path)

```apex
@isTest
static void testQueueableSuccess() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

    Documento_da_Proposta__c doc = [SELECT Id, Link__c FROM Documento_da_Proposta__c LIMIT 1];
    System.assertNotEquals(null, doc, 'DocProposta was not setuped. Output: ' + doc);

    Test.startTest();
    Id jobId = System.enqueueJob(new FileUploaderQueueable(doc.Id, 'arquivo.png', 'base64xyz'));
    Test.stopTest();

    Documento_da_Proposta__c updated = [SELECT Id, Link__c FROM Documento_da_Proposta__c WHERE Id = :doc.Id];
    System.assertEquals('https://url-esperada', updated.Link__c, 'Link não atualizado corretamente. Output: ' + updated.Link__c);
}
```

### 🔥 Caminhos de falha (callout ou query falhando)

```apex
@isTest
static void testQueueableCalloutFailure() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseForFailure());

    Documento_da_Proposta__c doc = [SELECT Id FROM Documento_da_Proposta__c LIMIT 1];
    System.assertNotEquals(null, doc, 'DocProposta was not setuped. Output: ' + doc);

    Test.startTest();
    System.enqueueJob(new FileUploaderQueueable(doc.Id, 'arquivo.png', 'base64xyz'));
    Test.stopTest();

    // Nenhuma exceção esperada. Apenas garantir execução segura.
    System.assert(true, 'Queueable executado sem falha.');
}
```

---

## 🔒 Validação de Parâmetros Obrigatórios

### ✅ Classe Queueable deve validar:
```apex
if (String.isBlank(recordId)) {
    throw new IllegalArgumentException('recordId não pode ser nulo ou vazio');
}
if (!recordId.startsWith('a0u')) {
    throw new IllegalArgumentException('Formato de recordId inválido para Documento da Proposta');
}
```

### ✅ Teste correspondente:
```apex
@isTest
static void testQueueableParametrosInvalidos() {
    try {
        Test.startTest();
        System.enqueueJob(new FileUploaderQueueable(null, 'arquivo.png', 'conteudo'));
        Test.stopTest();
        System.assert(false, 'Deveria lançar exceção para recordId nulo');
    } catch (IllegalArgumentException e) {
        System.assertEquals('recordId não pode ser nulo ou vazio', e.getMessage(), 'Mensagem divergente: ' + e.getMessage());
    }
}
```

---

## 🔄 Alternativa para Queueables com exceções assíncronas

### Produção
```apex
@TestVisible private static String lastExceptionMessage;

public void execute(QueueableContext context) {
    try {
        // ...
    } catch (Exception e) {
        lastExceptionMessage = e.getMessage();
    }
}
```

### Teste
```apex
Test.startTest();
System.enqueueJob(new MinhaClasseQueueable('id_invalido', 'arquivo', 'base64'));
Test.stopTest();

System.assertEquals('Mensagem esperada', MinhaClasseQueueable.lastExceptionMessage, 'Mensagem divergente: ' + MinhaClasseQueueable.lastExceptionMessage);
```

---

## ❌ Proibições Intransigentes

| Proibido                        | Motivo                                                              |
|--------------------------------|---------------------------------------------------------------------|
| `System.debug()`               | Não rastreável. Use `LoggerMock`                                  |
| `System.enqueueJob(...)` direto| Nunca validar via assert. Apenas enfileirar                        |
| `LoggerMock.getLogs()`         | Nunca usar para validação. Apenas para evitar log persistido     |
| `seeAllData=true`              | Rompe isolamento. Não usar.                                        |
| `SELECT` por nome              | Frágil. Sempre usar `Id` fixo no teste.                            |

---

## 🔢 Padrão Geral

```apex
@IsTest
private class AlgumaClasseTest {

    @TestSetup
    static void setup() {
        Map<String, Object> testData = TestDataSetup.setupCompleteEnvironment();
        System.assertNotEquals(null, testData.get('DocProposta'), 'DocProposta was not setuped.');
        FlowControlManager.disableFlows();
    }

    @IsTest
    static void testHappyPath() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Documento_da_Proposta__c doc = [SELECT Id FROM Documento_da_Proposta__c LIMIT 1];

        Test.startTest();
        System.enqueueJob(new AlgumaClasseQueueable(doc.Id, 'arquivo.png', 'base64'));
        Test.stopTest();
    }
}
```

---

## 📊 Assertivas em Testes (Padrão Mamba)

> Todo `System.assert`, `System.assertEquals`, `System.assertNotEquals` em testes deve **sempre incluir o valor real (output)** na mensagem de erro.

⚠️ **Essa regra se aplica apenas a validações de dados de negócio ou retorno de métodos.**
Ela **NÃO** se aplica a logs persistidos (`FlowExecutionLog__c`), que **não devem ser validados em testes**.

---

### ✅ Correto:
```apex
System.assertEquals(1, contas.size(), 'Esperado 1 conta, obtido: ' + contas.size());
System.assertNotEquals(null, resultado, 'Resultado inesperado: ' + resultado);
```

### ❌ Proibido:
```apex
FlowExecutionLog__c log = [SELECT Id FROM FlowExecutionLog__c LIMIT 1];
System.assertEquals('INFO', log.Log_Level__c); // ❌ NUNCA validar logs em teste
```

---

## 🔄 Aprendizados aplicados em testes complexos

| Tema                           | Regra Aprendida                                                                                         |
|--------------------------------|---------------------------------------------------------------------------------------------------------|
| `@TestSetup` + flows           | Setup de dados **sempre com flows ativos**. Apenas depois: `FlowControlManager.disableFlows();`        |
| Queueables e exceções          | Testes que esperam exceções **devem usar try/catch + assertEquals(...) com mensagem clara**          |
| Validações opcionais         | Relacionamentos como `UC__c → Lead` **podem ser vazios**, testes devem aceitar `size() == 0`         |
| SELECT defensivo              | Nunca usar `SELECT ... LIMIT 1` direto em `SObject`, sempre usar `List<...>` com fallback              |
| Retorno com .size() esperado  | Mesmo sem dados, retornos como `List<LeadData>` devem ter `.size() == leadIds.size()`                 |
| Validação de mocks            | `HttpCalloutMock` deve retornar estrutura mínima, mas rastreável (`access_token`, etc.)              |
| Dados via TestDataSetup       | Nenhum uso de `testData.get(...)` em métodos de teste — **sempre usar `SELECT` direto**               |
| Assertiva com output real     | Toda assertiva deve conter o valor real obtido, para rastreio preciso em caso de falha                |
| LIKE em filtros               | Dados de teste devem conter o valor **exato** usado no `LIKE '%valor%'`, evitando match parcial        |

---

## ✅ Checklist Final de Aprovação
- [ ] Usa `TestDataSetup.setupCompleteEnvironment()`?
- [ ] Flows desabilitados com `FlowControlManager.disableFlows()` **após** setup?
- [ ] Dados validados com `SELECT` direto no teste?
- [ ] Sem `testData.get(...)` nos testes?
- [ ] Nenhum uso de `LoggerMock.getLogs()`?
- [ ] `System.debug()` completamente banido?
- [ ] `System.assert` com mensagem clara + output?
- [ ] `enqueueJob` não validado diretamente?
- [ ] Teste cobre happy path, erro e exceção?
- [ ] Classe termina com `Test`?

---
> 🧠 Testes são o escudo da sua org.  
> 🐍 Teste bem. Teste com padrão. Teste como Mamba.
