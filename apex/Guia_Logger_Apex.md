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

