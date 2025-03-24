# 🧪 Guia Rigoroso de Testes Apex (Versão Estendida 2025)

> 🌐 Base: https://bit.ly/GuiaTestsApex

📎 Consulte também os guias complementares:
- 📘 [Guia de Revisão Apex](https://bit.ly/GuiaApexRevisao)
- 🧪 [Guia de Logger + LoggerContext](https://bit.ly/GuiaLoggerApex)
- 🔁 [Template de Comparação Antes vs Depois](https://bit.ly/ComparacaoApex)
- 🧱 [Classe TestDataSetup Central](https://bit.ly/TestDataSetup)
- ✅ [Confirmação de Equivalência Funcional](https://bit.ly/ConfirmacaoApex)

---

## ✅ Objetivo
Padronizar a estrutura, cobertura e qualidade dos testes Apex com base nos princípios do Revisor Rigoroso:
- Clareza estrutural
- Cobertura funcional e de exceções
- Dados consistentes e reutilizáveis

---

## ⚙️ Regras Obrigatórias

### 1. Setup obrigatório de ambiente (único por classe)
```apex
@TestSetup
static void setupTestData() {
    TestDataSetup.setupCompleteEnvironment();
    FlowControlManager.disableFlows();
}
```
❌ Nunca invocar `setupCompleteEnvironment()` dentro de métodos de teste individualmente.
✅ Cada método de teste deve fazer `SELECT` dos registros criados no `@TestSetup`. 
❌ Não é permitido reaproveitar `Map<String, SObject>` criado no `@TestSetup`, pois pode gerar inconsistência no escopo de execução.

### 2. Uso obrigatório de `LoggerMock`
```apex
LoggerMock logger = new LoggerMock();
LoggerContext.setLogger(logger);
```
❌ Nunca validar execução real de logs com `LoggerQueueable`, pois é assíncrono.
✅ O uso do mock permite isolar efeitos colaterais e garantir rastreabilidade.

### 3. Proibição de chamadas assíncronas reais
- Proibido:
```apex
System.enqueueJob(...);
```
- Use somente simulação com `LoggerMock`

### 4. Cobertura de cenário obrigatória
| Tipo de Cenário        | Exigido? |
|------------------------|----------|
| Cenário positivo       | ✅        |
| Cenário inválido       | ✅        |
| Exceções esperadas     | ✅        |
| Logs simulados (mock)  | ⚠️ **Não validar conteúdo dos logs** |

### 5. `RestContext.response` obrigatório em testes REST
```apex
RestContext.response = new RestResponse();
```
Caso contrário, pode ocorrer `NullPointerException` em produção

### 6. Métodos internos testáveis
- Use `@TestVisible` em toda lógica interna
- Prefira métodos com parâmetros fáceis de simular

---

## 🔕 Logs em Testes – Diretriz Oficial

- 🚫 **Não valide logs em testes** (nem com `LoggerMock.getLogs()`)
- ✅ `LoggerMock` deve ser usado apenas para **isolar efeitos colaterais**
- ✅ É permitido usar `System.debug()` em testes para depuração, especialmente quando `LoggerQueueable` é simulado
- ❌ Nunca use `System.debug()` em código de produção


---

## 🧱 Estrutura de Classe de Teste

```apex
@isTest
private class MinhaClasseTest {

    @TestSetup
    static void setup() {
        TestDataSetup.setupCompleteEnvironment();
        FlowControlManager.disableFlows();
    }

    @isTest
    static void testePrincipal() {
        LoggerMock logger = new LoggerMock();
        LoggerContext.setLogger(logger);

        // Buscar dados criados no setup
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        // chamada real ao método testado
        Test.stopTest();

        System.assertEquals(true, true); // exemplo
    }
}
```

---

## 📎 Validações recomendadas

### ⚠️ Não validar diretamente conteúdo de LoggerQueueable
- Logger real é assíncrono → não confiável em `stopTest()`
- Sempre usar `LoggerMock` apenas para impedir efeitos colaterais
- Não fazer asserts sobre `LoggerMock.getLogs()`

---

## 📄 Checklist Final para Classe de Teste
- [ ] Usa `@isTest`, `@TestSetup`, `Test.startTest()` e `Test.stopTest()`
- [ ] Usa `LoggerMock` e `LoggerContext.setLogger(...)`
- [ ] Usa `TestDataSetup.setupCompleteEnvironment()` apenas no `@TestSetup`
- [ ] Busca registros com `SELECT` no corpo do teste (nunca reaproveita `Map`)
- [ ] Simula `RestContext.response` se testar REST
- [ ] Possui testes para positivos, inválidos e exceções
- [ ] Possui cobertura de métodos `@TestVisible`
- [ ] Não usa `enqueueJob()` real
- [ ] ⚠️ Não valida execução nem conteúdo de logs assíncronos
- [ ] Não valida conteúdo de logs gerados (logger é assíncrono)
- [ ] Usa `System.debug()` apenas se necessário e somente em testes


---

> ⭐ Versão 2025 com aprendizados derivados de revisões reais com Apex Revisor Rigoroso

