# 🧪 Guia Rigoroso de Logger em Apex

> 🌐 Base: https://bit.ly/GuiaLoggerApex

📎 Consulte também os guias complementares:
- 📘 [Guia de Revisão Apex](https://bit.ly/GuiaApexRevisao)
- 🧪 [Guia de Testes Apex](https://bit.ly/GuiaTestsApex)
- 🔁 [Template de Comparação Antes vs Depois](https://bit.ly/ComparacaoApex)
- 🧱 [Classe TestDataSetup Central](https://bit.ly/TestDataSetup)
- ✅ [Confirmação de Equivalência Funcional](https://bit.ly/ConfirmacaoApex)

---

## ✅ Objetivo
Padronizar 100% dos logs Apex com base em `LoggerContext`, `LoggerQueueable` e `LoggerMock`, garantindo:
- Rastreabilidade total (11 parâmetros obrigatórios)
- Flexibilidade em produção e testes
- Integração com `LoggerMock` para simulação
- Segurança em ambientes assíncronos

---

## 🧱 LoggerContext: padrão obrigatório

### 🔐 Interface única para todos os logs:
```apex
LoggerContext.getLogger().log(
    Logger.LogLevel.INFO,
    className,
    methodName,
    triggerRecordId,
    mensagem,
    detalheTecnico,
    stackTrace,
    dadosSerializados,
    triggerType,
    logCategory,
    environment
);
```

### 🎯 Campos obrigatórios (ordem fixa):
1. `Logger.LogLevel` (DEBUG, INFO, WARNING, ERROR)
2. `className`
3. `methodName`
4. `triggerRecordId` (pode ser `null`)
5. `mensagem` (explicação legível do evento)
6. `detalheTecnico` (SQL, input, etc)
7. `stackTrace` (em caso de erro)
8. `dadosSerializados` (opcional)
9. `triggerType` (REST, Batch, Trigger, etc)
10. `logCategory` (Apex, Service, API...)
11. `environment` (Label.ENVIRONMENT)

---

## 🧰 Wrappers recomendados (boas práticas)

### ✅ logInfo
```apex
private static void logInfo(String message, String method) {
    LoggerContext.getLogger().log(
        Logger.LogLevel.INFO,
        className,
        method,
        null,
        message,
        null,
        null,
        null,
        triggerType,
        logCategory,
        environment
    );
}
```

### ✅ logError
```apex
private static void logError(String message, String method, Exception ex) {
    LoggerContext.getLogger().log(
        Logger.LogLevel.ERROR,
        className,
        method,
        null,
        message,
        ex.getMessage(),
        ex.getStackTraceString(),
        null,
        triggerType,
        logCategory,
        environment
    );
}
```

---

## 🧪 LoggerMock (testes unitários)

### ⚠️ NUNCA usar `System.enqueueJob(...)` em testes
- Ao testar logs, use:
```apex
LoggerMock logger = new LoggerMock();
LoggerContext.setLogger(logger);
```

### ⚠️ Não validar conteúdo do log
- `LoggerQueueable` é assíncrono — conteúdo não é garantido
- `LoggerMock` serve apenas para prevenir execução real

---

## 🧩 Comportamento por ambiente

| Ambiente       | LoggerContext.getLogger() retorna          |
|----------------|--------------------------------------------|
| Produção       | LoggerQueueable (enfileira log)            |
| Teste unitário | LoggerMock (evita enqueue)                 |

---

## 🛑 Proibições Absolutas

- ❌ `System.debug()` em produção
- ❌ `LoggerMock.getLogs()` para validação de mensagens
- ✅ `System.debug()` é **permitido em testes**, quando `LoggerContext` é mockado


---

## 📎 Checklist de Logging por classe
- [ ] Usa `LoggerContext.getLogger().log(...)` com 11 parâmetros?
- [ ] Usa `logInfo(...)` e `logError(...)` como abstrações?
- [ ] Classe define no topo:
  - `environment`
  - `log_level`
  - `className`
  - `triggerType`
  - `logCategory`
- [ ] Em testes, usa `LoggerMock`
- [ ] Nunca usa `enqueueJob()` nos testes

---

> ⭐ Versão 2025 com base em integrações reais auditadas em projetos rigorosos
