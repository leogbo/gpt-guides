# 🪵 Guia Oficial de Logger Apex (v2025) – Mentalidade Mamba

📎 **Shortlink oficial:** [bit.ly/GuiaLoggerApex](https://bit.ly/GuiaLoggerApex)

> “Logar não é opcional. É sua única fonte de verdade em produção.” – Mentalidade Mamba 🧠🔥

Este guia define o padrão de **log estruturado, rastreável e persistente** da sua org Salesforce.
Todo sistema crítico, API, trigger, batch ou callout **deve seguir esta arquitetura**.

---

## 📚 Referência cruzada com guias complementares

- 📘 [Guia Master de Arquitetura](https://bit.ly/GuiaApexMamba)
- 🔍 [Guia de Revisão Apex](https://bit.ly/GuiaApexRevisao)
- 🧪 [Guia de Testes](https://bit.ly/GuiaTestsApex)
- 🧱 [Guia de TestData Setup](https://bit.ly/TestDataSetup)
- 🔁 [Comparações de Refatoração](https://bit.ly/ComparacaoApex)
- ✅ [Equivalência Funcional](https://bit.ly/ConfirmacaoApex)

---

## ✅ Fundamentos do Logger Mamba

- Nunca usar `System.debug()` fora de testes.
- Logger deve:
  - Identificar a classe/método
  - Registrar input/output
  - Ser rastreável por usuário, registro e execução
  - Gerar logs estruturados e auditáveis
- Logs **são persistidos no objeto `FlowExecutionLog__c`** e/ou enviados via `LoggerQueueable`

---

## ✅ Componentes padrão

| Componente               | Descrição                                                                 |
|--------------------------|---------------------------------------------------------------------------|
| `LoggerContext`          | Classe principal de logging (fluent interface)                            |
| `FlowExecutionLog__c`    | Objeto de persistência auditável de logs                                  |
| `LoggerQueueable`        | Persistência assíncrona via fila                                           |
| `ILogger`                | Interface para Logger e LoggerMock                                        |
| `LoggerMock`             | Evita persistência real durante testes                                    |
| `LoggerTest`             | Classe de teste do comportamento do logger                                 |

---

## ✅ Uso padrão do LoggerContext

```apex
LoggerContext.getLogger()
    .setMethod('executarAcao')
    .setRecordId(recordId)
    .setAsync(true)
    .error('Falha crítica ao validar dados', e, JSON.serializePretty(input));
```

---

## ✅ Formatos suportados

| Método         | Uso típico                                     |
|----------------|-------------------------------------------------|
| `.info(...)`   | Logs de operação normal                         |
| `.warn(...)`   | Algo incompleto mas não bloqueante              |
| `.error(...)`  | Falhas funcionais, exceções                     |
| `.success(...)`| Resultado esperado de operação importante       |

---

## ❌ Nunca usar:

```apex
System.debug('Algo quebrou: ' + ex.getMessage()); // ❌
```

🔁 Use:
```apex
LoggerContext.getLogger().setMethod('executar').error('Erro', ex);
```

---

## ✅ Logger em Trigger

```apex
LoggerContext.getLogger()
    .fromTrigger(newRecord)
    .setMethod('beforeInsert')
    .warn('Validação parcial', JSON.serializePretty(newRecord));
```

---

## 🧪 Regras de teste para loggers

- Use `LoggerMock` em todos os testes unitários
- Nunca valide se o log foi persistido (é assíncrono!)
- Use `LoggerMock` apenas para impedir persistência:
```apex
LoggerContext.overrideLogger(new LoggerMock());
```

---

## 🧩 Integração com FlowExecutionLog__c

| Campo                  | Descrição                                     |
|------------------------|-----------------------------------------------|
| `Class__c`             | Nome da classe Apex                          |
| `Origin_Method__c`     | Método que originou o log                    |
| `Log_Level__c`         | DEBUG, INFO, WARNING, ERROR                 |
| `Log_Category__c`      | Domínio do log (Ex: Proposta, UC, API)      |
| `Serialized_Data__c`   | Payload serializado com `serializePretty()` |
| `Trigger_Type__c`      | Trigger, Queueable, REST, Batch             |
| `Error_Message__c`     | Mensagem da exceção                         |
| `Stack_Trace__c`       | Stack trace da exceção                      |

> 🔁 Referência completa: [bit.ly/FlowExecutionLog](https://bit.ly/FlowExecutionLog)

---

## 🧪 Exemplo de LoggerMock aplicado

```apex
@IsTest
static void test_erro_com_logger_mock() {
    LoggerContext.overrideLogger(new LoggerMock());

    Test.startTest();
    MinhaClasse.executarAlgo();
    Test.stopTest();

    System.assert(true, 'Logger executado com mock – não persistiu');
}
```

---

## ❌ Logs não devem ser validados em testes

| Item                     | Proibido       | Justificativa                               |
|--------------------------|----------------|---------------------------------------------|
| `FlowExecutionLog__c`    | ❌ não validar  | log é assíncrono                            |
| `LoggerQueueable`        | ❌ não esperar  | é fila, não sincroniza com o teste          |
| `LoggerMock.getLogs()`   | ❌ inválido     | logs são side-effect, não garantem ordenação|

---

## 📌 Boas práticas adicionais

- `LoggerContext.getLogger().setAsync(true)` deve ser usado em chamadas críticas
- Logs pesados devem usar `JSON.serializePretty()`
- Nunca logar senhas, tokens, headers, dados pessoais sem anonimizar
- Em REST, use `RestServiceHelper` com `.buildError(...)` que já loga internamente

---

## ✅ Checklist final para revisão de uso de Logger

| Item                                             | Verificado? |
|--------------------------------------------------|-------------|
| `.setMethod(...)` aplicado                       | [ ]         |
| `.setRecordId(...)` incluído se aplicável        | [ ]         |
| `.error(...)` com stack trace serializado        | [ ]         |
| `.success(...)` em finais de fluxo REST          | [ ]         |
| `LoggerMock` nos testes                          | [ ]         |
| `FlowExecutionLog__c` usado (se necessário)      | [ ]         |

---

🧠🧱🧪 #LoggerMamba #SemDebug #PersistênciaEstruturada #FalhaComRastro

**classes .cls**

/**
 * @since 2025-03-28
 * @author Leo Mamba Garcia
 * 
 * Classe `Logger`
 * 
 * Responsável por registrar logs de execução, erros e dados de auditoria com rastreabilidade completa.
 * A classe também oferece controle sobre o armazenamento de logs em produção ou testes.
 * 
 * ### Funcionalidade:
 * - **Logger** permite criar entradas de log com níveis de severidade (INFO, WARN, ERROR, SUCCESS).
 * - Os logs podem ser armazenados de forma síncrona ou assíncrona, conforme a configuração.
 * - Todos os dados de log são serializados para fácil análise.
 */
public class Logger {

    public enum LogLevel { INFO, WARN, ERROR, SUCCESS }

    @TestVisible public static String environment       = Label.ENVIRONMENT;
    @TestVisible public static String logLevelDefault   = 'INFO';
    @TestVisible public static Integer MAX_DEBUG_LENGTH = 3000;
    @TestVisible public static String className;
    @TestVisible public static String triggerType;
    @TestVisible public static String logCategory;
    @TestVisible public static Boolean isEnabled        = true;

    private String methodName;
    private String triggerRecordId;
    private String stackTrace;
    private String serializedData;
    private String instanceEnvironment;
    private String instanceClassName;
    private String instanceTriggerType;
    private String instanceLogCategory;
    private Boolean async = false;

    // Construtor padrão, que inicializa a classe com informações de contexto
    public Logger() {
        this.instanceClassName   = Logger.className;
        this.instanceTriggerType = Logger.triggerType;
        this.instanceLogCategory = Logger.logCategory;
        this.instanceEnvironment = Logger.environment;
    }

    // Métodos setters com @TestVisible para permitir a configuração e validação dos dados
    @TestVisible public Logger setMethod(String methodName) { this.methodName = methodName; return this; }
    @TestVisible public Logger setRecordId(String recordId) { this.triggerRecordId = recordId; return this; }
    @TestVisible public Logger setCategory(String category) { this.instanceLogCategory = category; return this; }
    @TestVisible public Logger setTriggerType(String triggerType) { this.instanceTriggerType = triggerType; return this; }
    @TestVisible public Logger setEnvironment(String environment) { this.instanceEnvironment = environment; return this; }
    @TestVisible public Logger setClass(String className) { this.instanceClassName = className; return this; }
    @TestVisible public Logger setAsync(Boolean value) { this.async = value; return this; }

    // Método de log para SUCCESS, com controle de dados e contexto
    @TestVisible public void success(String message, String data) {
        log(LogLevel.SUCCESS, message, null, data);
    }

    // Método de log para INFO, com controle de dados e contexto
    @TestVisible public void info(String message, String data) {
        log(LogLevel.INFO, message, null, data);
    }

    // Método de log para WARN, com controle de dados e contexto
    @TestVisible public void warn(String message, String data) {
        log(LogLevel.WARN, message, null, data);
    }

    // Método de log para ERROR, incluindo stack trace e dados do erro
    @TestVisible public void error(String message, Exception ex, String data) {
        String stack = (ex != null) ? ex.getStackTraceString() : null;
        log(LogLevel.ERROR, message, stack, data);
    }

    // Método privado para gerenciar o registro dos logs
    @TestVisible private void log(LogLevel level, String message, String stack, String data) {
        if (!isEnabled && !Test.isRunningTest()) return;

        FlowExecutionLog__c logEntry = new FlowExecutionLog__c(
            Log_Level__c           = level.name(),
            Class__c               = safeLeft(instanceClassName, 255),
            Origin_Method__c       = safeLeft(methodName, 255),
            Trigger_Record_ID__c   = triggerRecordId,
            Error_Message__c       = safeLeft(message, 255),
            Debug_Information__c   = safeLeft(message, MAX_DEBUG_LENGTH),
            Stack_Trace__c         = safeLeft(stack, 30000),
            Serialized_Data__c     = safeLeft(data, 30000),
            Trigger_Type__c        = instanceTriggerType,
            Log_Category__c        = instanceLogCategory,
            Environment__c         = instanceEnvironment,
            Execution_Timestamp__c = System.now()
        );

        // Registra o log de forma assíncrona ou síncrona conforme configuração
        if (async) {
            System.enqueueJob(new LoggerQueueable(logEntry));
        } else {
            insert logEntry;
        }
    }

    // Método privado para garantir que os valores não ultrapassem o limite de comprimento
    @TestVisible private String safeLeft(String value, Integer max) {
        return (value == null) ? null : value.left(max);
    }

    // Método para inicializar o Logger a partir de um registro SObject
    @TestVisible public static Logger fromTrigger(SObject record) {
        Logger logger = new Logger();
        if (record != null && record.Id != null) {
            logger.setRecordId(record.Id);
        }
        return logger;
    }
}

public interface ILogger {

    // ===== CONFIGURAÇÃO FLUENTE =====
    ILogger withMethod(String methodName);
    ILogger withRecordId(String recordId);
    ILogger withCategory(String category);
    ILogger withTriggerType(String triggerType);
    ILogger withEnvironment(String environment);
    ILogger withClass(String className);
    ILogger withAsync(Boolean value);

    // ===== MÉTODOS DE LOG =====
    void success(String message, String serializedData);
    void info(String message, String serializedData);
    void warn(String message, String serializedData);
    void error(String message, Exception ex, String serializedData);

    // ===== OPCIONAIS PARA MOCKS/VALIDAÇÃO =====
    void logRaw(String message);
    Map<String, Object> debugSnapshot();
}


public class LoggerMock implements ILogger {
    public List<String> capturedMessages = new List<String>();
    private Map<String, Object> context = new Map<String, Object>();
    
    @TestVisible
    public ILogger withMethod(String methodName) {
        context.put('method', methodName);
        return this;
    }
    
    @TestVisible
    public ILogger withRecordId(String recordId) {
        context.put('recordId', recordId);
        return this;
    }

    @TestVisible
    public ILogger withCategory(String category) {
        context.put('category', category);
        return this;
    }

    @TestVisible
    public ILogger withTriggerType(String triggerType) {
        context.put('triggerType', triggerType);
        return this;
    }

    @TestVisible
    public ILogger withEnvironment(String environment) {
        context.put('environment', environment);
        return this;
    }

    @TestVisible
    public ILogger withClass(String className) {
        context.put('class', className);
        return this;
    }

    @TestVisible
    public ILogger withAsync(Boolean value) {
        context.put('async', value);
        return this;
    }

    @TestVisible
    public void success(String message, String serializedData) {
        capturedMessages.add('[SUCCESS] ' + message + ' | ' + serializedData);
    }

    @TestVisible
    public void info(String message, String serializedData) {
        capturedMessages.add('[INFO] ' + message + ' | ' + serializedData);
    }

    @TestVisible
    public void warn(String message, String serializedData) {
        capturedMessages.add('[WARN] ' + message + ' | ' + serializedData);
    }

    @TestVisible
    public void error(String message, Exception ex, String serializedData) {
        String msg = message + (ex != null ? ' | ' + ex.getMessage() : '');
        capturedMessages.add('[ERROR] ' + msg + ' | ' + serializedData);
    }

    @TestVisible
    public void logRaw(String message) {
        capturedMessages.add('[RAW] ' + message);
    }

    @TestVisible
    public Map<String, Object> debugSnapshot() {
        return context.clone();
    }

    @TestVisible
    public List<String> getCaptured() {
        return capturedMessages;
    }
}

