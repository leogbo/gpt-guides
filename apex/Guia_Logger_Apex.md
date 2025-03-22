# 📝 Guia Rigoroso de Logging Apex

📅 Última atualização: MAR/2025

---

## 🎯 Objetivo

Padronizar 100% dos logs estruturados em Apex com:

- Interface obrigatória `ILogger`
- Proibição de `System.debug()`
- Logs contextualizados com `LoggerContext`
- Facilitação de testes com `LoggerMock`

---

## ✅ 1. Interface obrigatória: `ILogger`

Toda implementação deve respeitar os 11 parâmetros:

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

## ✅ 2. Uso obrigatório com `LoggerContext.getLogger().log(...)`

Exemplo padrão de chamada:

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

### ✅ Requisitos:

- Sempre 11 argumentos (mesmo que `null`)
- Usar `LoggerContext` como fonte de contexto
- Nomes de métodos devem refletir o real ponto de execução

---

## 🔧 3. Uso de `LoggerHelper` (atalho padronizado)

### 🔴 Log de erro com exceção:

```apex
LoggerHelper.logError(
    'Erro ao criar UC',
    'UcTestDataSetup',
    'createUC',
    ex,
    'test-data'
);
```

### 🟢 Log de sucesso ou info:

```apex
LoggerHelper.logInfo(
    'UC criada com sucesso',
    'UcTestDataSetup',
    'createUC',
    'test-data'
);
```

> ⚠️ `LoggerHelper` é obrigatório em todas as classes do tipo `*TestDataSetup`, Queueables, Triggers e Batches.

---

## 🧪 4. Validação de logs em testes (LoggerMock)

### Ativação:

```apex
LoggerContext.setLogger(new LoggerMock());
```

### Validação:

```apex
List<String> logs = ((LoggerMock) LoggerContext.getLogger()).getLogs();
System.assert(logs.any(l => l.contains('createUC')));
```

> Recomendado verificar também `LogLevel`, `className` e `methodName` quando necessário.

---

## 🚨 5. Proibições absolutas

| Proibido                                                       | Motivo                         |
|----------------------------------------------------------------|--------------------------------|
| `System.debug(...)`                                            | Não rastreável / não testável |
| Usar `log(...)` com menos de 11 parâmetros                     | Quebra do contrato da interface |
| `LoggerQueueable` sendo chamado diretamente dentro do `log`    | Causa recursão infinita       |
| `LoggerMock` sem ser injetado com `LoggerContext.setLogger()` | Log não capturado no teste     |

---

## 🔁 6. Cuidado com recursão de log

**Nunca** chamar `LoggerQueueable` de dentro de `LoggerQueueable`.

### Exemplo inválido:

```apex
// dentro do execute()
LoggerHelper.logError('Erro', 'LoggerQueueable', 'execute', ex, 'log');
```

> 🧨 Isso gerará um loop infinito de enfileiramento.

### Correto:
Use `System.debug()` somente se estiver em modo `Test.isRunningTest()`  
**ou** desative a chamada recursiva com `LoggerContext.disable()` (caso implementado).

---

## ✅ 7. Checklist de log para revisão

| Item                                                           | Status |
|----------------------------------------------------------------|--------|
| Usa `LoggerContext.getLogger().log(...)` com 11 parâmetros     | ✅     |
| Contexto preenchido (`className`, `methodName`, `triggerType`) | ✅     |
| Nenhum `System.debug(...)` presente no código                  | ✅     |
| Usa `LoggerHelper` em helpers e `*TestDataSetup`               | ✅     |
| Testes validam logs com `LoggerMock.getLogs()`                 | ✅     |

---

## 📌 Sugestão de organização de logs por categoria

| logCategory     | Descrição                                 |
|-----------------|-------------------------------------------|
| `api`           | Requisições REST externas                 |
| `batch`         | Processos em lote (`Batchable`)           |
| `trigger`       | Fluxos automáticos de trigger             |
| `test-data`     | Dados gerados para teste                  |
| `validation`    | Validações de campos, tokens, permissões  |
| `integration`   | Chamada a sistemas externos (HTTP, etc.)  |

---

✅ Esse guia deve ser aplicado em **100% das classes Apex que contenham logs, exceções ou fluxos REST**.

---

### 📎 Compatibilidade com os guias oficiais
- [ ] [Guia de Revisão Apex](https://bit.ly/GuiaApexRevisao)
- [ ] [Guia de Testes Apex](https://bit.ly/GuiaTestsApex)
- [ ] [Guia de Logging](https://bit.ly/GuiaLoggerApex)
- [ ] [Guia de Refatoração Apex](https://bit.ly/ComparacaoApex)
- [ ] [Classe orquestradora `TestDataSetup.cls`](https://bit.ly/TestDataSetup)
- [ ] [Checklist de Confirmação Final](https://bit.ly/ConfirmacaoApex)

---
