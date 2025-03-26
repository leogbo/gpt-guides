# ***** PENDENCIAS A INTEGRAR *****

Exatamente. Tivemos uma jornada completa com aprendizados valiosos que **merecem ser oficializados nos guias**, especialmente para Osmar, Marcio, e qualquer dev que for tocar código crítico da sua Org.

LINKS DE REFERENCIA
- https://bit.ly/GuiaApexRevisao
- https://bit.ly/GuiaLoggerApex
- https://bit.ly/Guia_APIs_REST
- https://bit.ly/GuiaTestsApex
- https://bit.ly/TestDataSetup
- https://bit.ly/ComparacaoApex
- https://bit.ly/ConfirmacaoApex

---

## 📘 Sugestão: Seção nova no GuiaTestsApex  
### 🧠 “Aprendizados aplicados em testes complexos”

### ✅ Exemplos a registrar:

| Tema | Regra Aprendida |
|------|------------------|
| `@testSetup` + flows   | Setup de dados **sempre com flows ativos**. Só depois: `FlowControlManager.disableFlows();` |
| Queueables e exceções  | Testes que esperam exceções **devem usar try/catch + assertEquals(...)** |
| Validações opcionais   | Relacionamentos como `UC__c → Lead` **podem ser vazios**, testes devem aceitar `size() == 0` |
| SELECT defensivo       | Nunca usar `SELECT ... LIMIT 1` direto em `SObject`, sempre usar `List<...>` com fallback |
| Métodos que retornam estruturas fixas | Mesmo sem dados, retornos como `List<LeadData>` devem ter `.size() == leadIds.size()` |
| Validação de mocks     | `HttpCalloutMock` deve retornar estrutura mínima, mas rastreável (`access_token`, etc.) |
| Dados via TestDataSetup | Nenhum uso de `testData.get(...)` em métodos de teste — **apenas `SELECT` direto** |
| Rastreamento de falha | Toda `System.assert` com mensagem clara e contextualizada |

---

Excelente. Esse código é uma **peça central da arquitetura REST da sua Org** e deve ser tratado como tal no manual.

---

### 📁 Proposta: Nova seção no Guia de Padrões REST
> ## 🔧 `RestServiceHelper`: Serviço Base de Suporte a RESTs

---

### 📘 Estrutura sugerida:

```md
## 🔧 RestServiceHelper – Classe Abstrata Base para Serviços REST

Esta classe é usada como base padrão para todos os serviços REST desenvolvidos internamente.  
Ela fornece:

- 🛡️ Validação de tokens de segurança
- 📦 Extração robusta do corpo da requisição
- 💬 Métodos padronizados para respostas HTTP (200, 400, 401, 404, 406, 500, etc.)
- 🔁 Mapeamento automático de campos de entrada JSON → SObject
- 🧪 Suporte direto a testes (`lastExceptionMessage`, overloads curtos)

---

### 🧱 Estrutura padrão da classe

```apex
// código completo que você enviou aqui
```

---

### 🧪 Casos de uso recomendados

| Situação | Método |
|----------|--------|
| Token inválido | `validateAccessToken(...)` → lança `AccessException` |
| Corpo ausente ou malformado | `getRequestBody()` → lança `BadRequestException` |
| Responder com erro genérico | `internalServerError(...)` |
| Confirmar update com sucesso | `accepted('Lead atualizado')` |
| Retornar 404 com detalhes | `notFound('Lead não encontrado', mapDeDetalhes)` |
| Aplicar JSON em SObject | `mapFieldsFromRequest(json, objeto, 'Lead')` |

---

### 🧱 Testes relacionados

> Consulte: `RestServiceHelperTest.cls` para cobertura de:
> - `validateAccessToken` com e sem token
> - `getRequestBody()` com JSON válido e inválido
> - `sendResponse` com código e mensagens
> - `mapFieldsFromRequest` com campos válidos e ignorados

---

## 🧠 Observações

- Todos os serviços REST novos devem extender ou usar essa classe como helper.
- O retorno deve sempre ser JSON padronizado.
- Testes unitários devem validar código HTTP e conteúdo da resposta.

```


# ***** FIM DAS PENDENCIAS A INTEGRAR *****


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
| T01 | ❌ `testData.get(...)` **proibido** dentro de métodos `@isTest`                                 | 🔒     |
| T02 | ❌ `setupTestData()` **jamais chamado manualmente** dentro de `@isTest`                       | 🔒     |
| T03 | ✅ Toda preparação de dados deve ocorrer exclusivamente em `@TestSetup`                    | ✅     |
| T04 | ❌ `FlowControlManager.disableFlows()` deve ser chamado apenas 1x no `@TestSetup`            | 🔒     |
| T05 | ❌ `createUser(..., true)` + `System.runAs()` externo causa `Test already started`           | 🔒     |
| T06 | ✅ `createUser(..., false)` + `runAs + startTest/stopTest` deve ser usado corretamente       | ✅     |
| T07 | ❌ Testes `isParallel=true` **não podem fazer DML em objetos restritos** (User, Profile)       | 🔒     |
| T08 | ✅ Sempre usar `SELECT` direto nos métodos `@isTest` (nunca depender de instância estática) | ✅     |
| T09 | ✅ Asserts devem ter mensagens claras e rastreáveis                                        | ✅     |
| T10 | ❌ `LoggerMock.getLogs()` **nunca** deve ser usado para validação (somente neutraliza log)     | 🔒     |
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
    System.assertNotEquals(null, doc, 'DocProposta was not setuped.');

    Test.startTest();
    Id jobId = System.enqueueJob(new FileUploaderQueueable(doc.Id, 'arquivo.png', 'base64xyz'));
    Test.stopTest();

    Documento_da_Proposta__c updated = [SELECT Id, Link__c FROM Documento_da_Proposta__c WHERE Id = :doc.Id];
    System.assertEquals('https://url-esperada', updated.Link__c);
}
```

### 🔥 Caminhos de falha (callout ou query falhando)

```apex
@isTest
static void testQueueableCalloutFailure() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseForFailure());

    Documento_da_Proposta__c doc = [SELECT Id FROM Documento_da_Proposta__c LIMIT 1];
    System.assertNotEquals(null, doc, 'DocProposta was not setuped.');

    Test.startTest();
    System.enqueueJob(new FileUploaderQueueable(doc.Id, 'arquivo.png', 'base64xyz'));
    Test.stopTest();

    // Sem assertivas: validamos apenas que nenhuma exceção foi lançada
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
        System.assertEquals('recordId não pode ser nulo ou vazio', e.getMessage());
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

System.assertEquals('Mensagem esperada', MinhaClasseQueueable.lastExceptionMessage);
```

---

## ❌ Proibições Intransigentes

| Proibido                        | Motivo                                                              |
|--------------------------------|---------------------------------------------------------------------|
| `System.debug()`                | Não rastreável. Use `LoggerMock`                                   |
| `System.enqueueJob(...)` direto | Nunca validar via assert. Apenas enfileirar                        |
| `LoggerMock.getLogs()`          | Nunca usar para validação. Apenas para evitar log persistido     |
| `seeAllData=true`               | Rompe isolamento. Não usar.                                        |
| `SELECT` por nome               | Fragíl. Sempre usar `Id` fixo no teste.                            |

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

## ✅ Checklist Final de Aprovação
- [ ] Usa `TestDataSetup.setupCompleteEnvironment()`?
- [ ] Flows desabilitados com `FlowControlManager.disableFlows()` **após** setup?
- [ ] Dados validados com `SELECT` direto no teste?
- [ ] Sem `testData.get(...)` nos testes?
- [ ] Nenhum uso de `LoggerMock.getLogs()`?
- [ ] `System.debug()` completamente banido?
- [ ] `System.assert` com mensagem clara?
- [ ] `enqueueJob` não validado diretamente?
- [ ] Teste cobre happy path, erro e exceção?
- [ ] Classe termina com `Test`?

---
> 🧠 Testes são o escudo da sua org.  
> 🐍 Teste bem. Teste com padrão. Teste como Mamba.

