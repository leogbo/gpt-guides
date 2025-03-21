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

