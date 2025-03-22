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


## ✅ Mocks obrigatórios para chamadas HTTP (mesmo quando null)

Regra nova adicionada ao guia:

Em qualquer teste que execute código com chamadas HTTP (HTTPRequest, HTTP.send()), o uso de Test.setMock(HttpCalloutMock.class, ...) é obrigatório, mesmo quando a resposta esperada é null, erro ou exceção.

📌 Isso evita:

UnexpectedException por res == null

Falhas de integração simulada

Interrupção do batch/teste silenciosamente

✅ Mocks devem retornar HttpResponse válidos, nunca null diretamente

---

## 🎯 Cobertura de testes

- Cenário positivo (sucesso)
- Cenário negativo (erro esperado)
- Cenário de exceção (try/catch validando falha)


---
