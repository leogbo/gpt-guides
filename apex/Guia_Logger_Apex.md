A seguir está a **nova versão oficial revisada do guia `Logger`**, já refletindo:

- Contexto estático por classe  
- Logger fluente por instância  
- Suporte a async via `LoggerQueueable`  
- Mock isolado via `ILogger` e `LoggerMock`  
- Testabilidade e rastreabilidade total

---

# 🧱 Guia Oficial de Logging Apex – Versão Atualizada

> **Nome oficial:** `Logger`  
> **Versão:** v2 – Arquitetura Fluent + Interface + Queueable  
> **Status:** 🟢 Ativa em produção

---

## ✅ Princípios Fundamentais

| Ponto                     | Regra                                                                 |
|---------------------------|-----------------------------------------------------------------------|
| 🔁 Contexto por classe    | Definido via `Logger.className`, `Logger.triggerType`, etc.          |
| 🧠 Logger por instância   | Declarado com `new Logger()` e mantido como `static final`            |
| 🔧 Setters fluentes       | Usar `.setMethod()`, `.setAsync()`, etc.                              |
| 🔄 Execução assíncrona    | Controlada com `.setAsync(true)` → usa `LoggerQueueable`              |
| 🔕 Desativação global     | Via `Logger.isEnabled = false`                                        |
| 🧪 Mock para testes       | Usar `LoggerMock implements ILogger`                                  |
| 🧱 Integração total       | Logger implementa `ILogger`                                           |
| 🧩 De onde usar           | Triggers, Flows, Batches, Controllers, Services                       |

---

## 📐 Formato de uso por padrão

### 1. Contexto global por classe
```apex
static {
    Logger.className   = 'MinhaClasse';
    Logger.triggerType = 'Apex';
    Logger.logCategory = 'FluxoConta';
    Logger.environment = Label.ENVIRONMENT;
}
```

### 2. Logger fixo por classe
```apex
static final ILogger log = new Logger();
```

### 3. Uso no método
```apex
log.setMethod('executarValidador')
   .setRecordId(conta.Id)
   .setAsync(true)
   .error('Erro ao validar CNPJ', ex, JSON.serialize(conta));
```

---

## ✅ Métodos disponíveis

```apex
Logger.setMethod(String)
Logger.setRecordId(String)
Logger.setCategory(String)
Logger.setClass(String)
Logger.setEnvironment(String)
Logger.setAsync(Boolean)

Logger.success(String msg, String data)
Logger.info(String msg, String data)
Logger.warn(String msg, String data)
Logger.error(String msg, Exception ex, String data)
```

---

## 🧩 Modo Trigger

```apex
Logger.fromTrigger(sObj)
      .setMethod('afterInsert')
      .error('Erro no fluxo', ex, JSON.serialize(sObj));
```

---

## 🧪 Testes

### Desativar global
```apex
Logger.isEnabled = false;
```

### Usar mock
```apex
LoggerMock mock = new LoggerMock();
mock.setMethod('testeUnitario').info('Simulação de log', null);

System.assert(mock.getCaptured().size() > 0);
```

---

## 🛡️ Boas práticas

| ❌ Evitar                          | ✅ Fazer                                               |
|-----------------------------------|--------------------------------------------------------|
| `new Logger('MinhaClasse')`       | Usar `Logger.className = '...'` + `new Logger()`       |
| `System.debug()` em produção      | Usar `.info()`, `.warn()` com JSON e rastreio completo |
| Logging direto no handler         | Injetar logger e manter contexto                       |
| `Test.isRunningTest()` nos testes | Preferir `LoggerMock` ou `Logger.isEnabled = false`    |

---

## 🧠 Avanços futuros possíveis

- Filtragem por categoria (`LoggerCategoryManager`)
- Fallback assíncrono para falha de insert
- Dashboards de logs por Flow/Trigger/User

---

## 📦 Classes envolvidas

| Classe              | Papel principal                                   |
|---------------------|---------------------------------------------------|
| `ILogger`           | Interface contratual                              |
| `Logger`            | Implementação padrão                              |
| `LoggerQueueable`   | Executor assíncrono via `Queueable`               |
| `LoggerMock`        | Simulador de log sem insert real                  |
| `LoggerTest`        | Testes de integração padrão                       |
| `LoggerQueueableTest` | Testes do executor assíncrono                   |

---

Se quiser, posso agora:

- Gerar versão `.md` ou `.pdf` para documentação técnica
- Atualizar **outros guias**: `TestDataSetup`, `GuiaTestsApex`, `GuiaLoggerApex`

Confirma prioridade dos próximos guias? Ou gera o `.md` deste?
