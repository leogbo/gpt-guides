************** PENDENCIAS PARA INTEGRAR ****************

✏️ Complementar: Logs de entrada inválida
Adicionar exemplo:

apex
Copiar
Editar
if (String.isBlank(recordId)) {
    Logger.error('recordId vazio. Encerrando execução.');
    throw new IllegalArgumentException('recordId obrigatório');
}
🧠 Toda exceção lançada deve ser precedida de log explícito com Logger.error (em produção).

💡 Sugestão: Consolidar uma nova seção nos guias
📂 Validação de Entradas e Assertivas em Testes

Onde centralizamos todas as regras que reforçam a importância de:

Validar parâmetros de entrada

Gerar exceções explícitas e previsíveis

Garantir que testes que esperam falha de fato cobrem essa falha

************** FRIM DAS PENDENCIAS ****************

# 🧱 Guia Oficial de Logging Apex (`Logger`) – v2.0  
_Fluent Interface • Async via Queueable • Testável com Mock_

---

## 📎 Guias complementares

- 🧪 [Guia de Testes Apex](https://bit.ly/GuiaTestsApex)
- 🪵 [Guia de Logger com Interface + Queueable](https://bit.ly/GuiaLoggerApex)
- 🔁 [Template de Comparação Antes vs Depois](https://bit.ly/ComparacaoApex)
- 🧱 [Classe TestDataSetup Central](https://bit.ly/TestDataSetup)
- ✅ [Checklist de Equivalência Funcional](https://bit.ly/ConfirmacaoApex)

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
    Logger.isEnabled   = true;
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

### 🔧 Configuração

```apex
setMethod(String)
setRecordId(String)
setCategory(String)
setClass(String)
setEnvironment(String)
setAsync(Boolean)
```

### 📝 Ações de log

```apex
success(String message, String serializedData)
info(String message, String serializedData)
warn(String message, String serializedData)
error(String message, Exception ex, String serializedData)
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

> ⚠️ Nunca validar insert real de `LoggerQueueable` em teste. É assíncrono e não garante persistência visível.

---

## 🛡️ Boas práticas

| ❌ Evitar                          | ✅ Fazer                                               |
|-----------------------------------|--------------------------------------------------------|
| `new Logger('MinhaClasse')`       | Usar `Logger.className = '...'` + `new Logger()`       |
| `System.debug()` em produção      | Usar `.info()`, `.warn()` com JSON e rastreio completo |
| Logging hardcoded no handler      | Injetar `ILogger log = new Logger();`                  |
| `Test.isRunningTest()` nos testes | Usar `LoggerMock` ou `Logger.isEnabled = false`        |

---

## 🧠 Avanços futuros possíveis

- Filtragem por categoria (`LoggerCategoryManager`)
- Fallback assíncrono para falha de insert
- Dashboards de logs por Flow/Trigger/User

---

## 📦 Classes envolvidas

| Classe                | Papel principal                                 |
|-----------------------|-------------------------------------------------|
| `ILogger`             | Interface contratual                            |
| `Logger`              | Implementação padrão                            |
| `LoggerQueueable`     | Executor assíncrono via `Queueable`             |
| `LoggerMock`          | Simulador de log sem insert real                |
| `LoggerTest`          | Testes de integração padrão                     |
| `LoggerQueueableTest` | Testes do executor assíncrono                   |

---

🧠 Mantenha consistência.  
🧪 Teste tudo.  
🐍 Rastreie como um Mamba.
