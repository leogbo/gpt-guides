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

## 🎯 Cobertura de testes

- Cenário positivo (sucesso)
- Cenário negativo (erro esperado)
- Cenário de exceção (try/catch validando falha)


---

# 📝 Guia Rigoroso de Logging Apex

## ✅ Interface obrigatória: `ILogger`

```apex
void log(
    Logger.LogLevel level,
    String className,
    String methodName,
    String triggerRecordId,
    String errorMessage,
    String debugInformation,
    String stackTrace,
    String serializedData,
    String triggerType,
    String logCategory,
    String env
);
```

---

## ✅ Uso via `LoggerContext.getLogger().log(...)`

```apex
LoggerContext.getLogger().log(
    Logger.LogLevel.INFO,
    LoggerContext.className,
    'createAccount',
    null,
    'Conta criada com sucesso',
    null,
    null,
    null,
    LoggerContext.triggerType,
    LoggerContext.logCategory,
    LoggerContext.environment
);
```

---

## ❌ Sintaxes proibidas

- `System.debug()`
- `LoggerContext.getLogger().log(...)` com menos de 11 parâmetros
- `log => log.contains(...)` (sintaxe inválida em Apex)

---

## ✅ LoggerHelper

### Padrão para logs de erro com Exception:

```apex
LoggerHelper.logError(
    'Erro ao criar UC',
    'UcTestDataSetup',
    'createUC',
    e,
    'test-data'
);
```

### Padrão para logs de informação:

```apex
LoggerHelper.logInfo(
    'UC criada com sucesso',
    'UcTestDataSetup',
    'createUC',
    'test-data'
);
```

---

## 🔁 Cuidado com recursão de log

Nunca fazer:
```apex
logError(...) // que chama LoggerQueueable // que chama logError() de novo
```

---

✅ Use `LoggerHelper` em todos os `*TestDataSetup`, Queueables, Triggers e Batches.

