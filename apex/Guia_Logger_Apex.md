# 📘 Guia Rigoroso de Logging com LoggerQueueable, LoggerContext e ILogger

Este guia padroniza o uso de logs no ecossistema Apex, substituindo o uso direto de `System.enqueueJob(new LoggerQueueable(...))` por uma arquitetura baseada em **injeção de dependência via `ILogger` e `LoggerContext`**.

---

## 🎯 Objetivos

- Garantir que todos os logs sejam rastreáveis, controláveis e testáveis
- Evitar múltiplos `enqueueJob()` em testes e ambientes sensíveis
- Permitir que logs sejam desativados ou redirecionados dinamicamente
- Permitir que testes simulem logs com `LoggerMock`

---

## 🧱 Componentes da Arquitetura

### 1. `ILogger` (interface)
```apex
public interface ILogger {
    void log(
        String level,
        String methodName,
        String errorMessage,
        String debugInformation,
        String stackTrace,
        String serializedData
    );
}
```

---

### 2. `LoggerReal` (implementação real)

```apex
public class LoggerReal implements ILogger {
    public void log(String level, String methodName, String errorMessage, String debugInformation, String stackTrace, String serializedData) {
        System.enqueueJob(new LoggerQueueable(
            level,
            methodName,
            LoggerContext.className,
            null,
            errorMessage,
            debugInformation,
            stackTrace,
            serializedData,
            LoggerContext.triggerType,
            LoggerContext.logCategory,
            LoggerContext.environment
        ));
    }
}
```

---

### 3. `LoggerMock` (para testes)

```apex
public class LoggerMock implements ILogger {
    private List<String> logs = new List<String>();

    public void log(String level, String methodName, String errorMessage, String debugInformation, String stackTrace, String serializedData) {
        logs.add('[' + level + '] ' + methodName + ': ' + errorMessage);
        System.debug('[MOCK LOG] ' + errorMessage);
    }

    public List<String> getLogs() {
        return logs;
    }
}
```

---

### 4. `LoggerContext` (orquestrador de logging)

```apex
public class LoggerContext {
    public static String environment   = Label.ENVIRONMENT;
    public static String log_level     = Label.LOG_LEVEL;
    public static String className     = 'LoggerContext';
    public static String triggerType   = 'Apex';
    public static String logCategory   = 'System';

    private static ILogger loggerInstance;

    public static ILogger getLogger() {
        if (loggerInstance != null) return loggerInstance;
        loggerInstance = Test.isRunningTest() ? (ILogger) new LoggerMock() : (ILogger) new LoggerReal();
        return loggerInstance;
    }

    @TestVisible
    public static void setLogger(ILogger customLogger) {
        loggerInstance = customLogger;
    }

    public static void resetLogger() {
        loggerInstance = null;
    }
}
```

---

## ✅ Como usar corretamente

### Antes (ERRADO):

```apex
System.enqueueJob(new LoggerQueueable(...));
```

### Depois (CORRETO):

```apex
LoggerContext.className = 'MinhaClasse';
LoggerContext.triggerType = 'REST';
LoggerContext.logCategory = 'Integration';

LoggerContext.getLogger().log(
    'ERROR',
    'meuMetodo',
    'Erro ao executar...',
    'info debug',
    'stack trace',
    'dados serializados'
);
```

---

## 🧪 Testes com LoggerMock

Em testes, configure o logger:

```apex
LoggerMock mock = new LoggerMock();
LoggerContext.setLogger(mock);
```

Verifique logs gerados:

```apex
Boolean encontrou = false;
for (String log : mock.getLogs()) {
    if (log.contains('esperado')) {
        encontrou = true;
        break;
    }
}
System.assert(encontrou, 'Esperava log...');
```

---

## 🧼 Boas práticas

| Recomendação | Justificativa |
|--------------|---------------|
| Sempre configure `LoggerContext.className` | Torna os logs rastreáveis |
| Use `LoggerMock` em 100% dos testes | Evita limite de `enqueueJob()` |
| Sempre envie `null` explicitamente em parâmetros não utilizados | Garante assinatura compatível |
| Não reaproveite `LoggerQueueable` diretamente | Ele deve ser usado **somente via LoggerReal** |

---

## ❌ Erros comuns

- Esquecer de setar `LoggerContext` (classe, trigger, categoria)
- Passar apenas 3-4 parâmetros para `log()` (são **6 obrigatórios**)
- Usar `System.enqueueJob(...)` direto em produção
- Usar `System.debug()` fora de testes
- Tentar acessar `FlowExecutionLog__c` diretamente nos testes

---

## ✅ Conclusão

Este padrão permite:
- Testabilidade real
- Logs controlados por ambiente e nível
- Aderência 100% ao Guia Rigoroso
- Arquitetura escalável e desacoplada de infraestrutura

**Todo novo log em Apex deve usar `LoggerContext.getLogger().log(...)`.**

---
