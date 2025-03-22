## ✅ Guia Rigoroso de Revisão Apex (Versão Atualizada)

```markdown
# ✅ Guia Rigoroso de Revisão Apex

Última atualização: MAR/2025

---

## 📌 Princípios Fundamentais

1. **Cada classe deve ter uma única responsabilidade (SRP)**
2. **Todos os logs devem usar `LoggerContext.getLogger().log(...)` com 11 parâmetros**
3. **Testes devem usar `LoggerMock` + `TestDataSetup.setupCompleteEnvironment()`**
4. **`System.debug()` é terminantemente proibido**
5. **Uso obrigatório de `LoggerHelper` para padronizar logs**

---

## 🧱 Estrutura obrigatória de classes

Cada classe deve conter no topo:

```apex
public static final String environment = 'test';
public static final Logger.LogLevel log_level = Logger.LogLevel.DEBUG;
public static final String className = '<NOME_DA_CLASSE>';
public static final String triggerType = '<Batch | Trigger | Apex>';
public static final String logCategory = '<domínio funcional>';
```

---

## 📝 Logging padronizado

Use **somente** a interface `ILogger` com todos os **11 parâmetros obrigatórios**:

```apex
LoggerContext.getLogger().log(
    Logger.LogLevel.INFO,
    LoggerContext.className,
    'nomeDoMetodo',
    null,
    'mensagem de erro',
    'debug info',
    'stacktrace',
    null,
    LoggerContext.triggerType,
    LoggerContext.logCategory,
    LoggerContext.environment
);
```

Use `LoggerHelper.logInfo(...)` e `logError(...)` sempre que possível nos módulos de teste.

---

## 🧪 Testes rigorosos

- Testes devem usar:

```apex
LoggerContext.setLogger(new LoggerMock());
```

- E validar logs com:

```apex
List<String> logs = ((LoggerMock) LoggerContext.getLogger()).getLogs();
System.assert(logs.anyMatch(l => l.contains('createAccount')));
```

- Ou com loop:

```apex
Boolean encontrou = false;
for (String log : logs) {
    if (log.contains('createUC')) {
        encontrou = true;
        break;
    }
}
System.assertEquals(true, encontrou);
```

🔒 Mocks obrigatórios para chamadas HTTP (mesmo quando null)

Regra nova adicionada ao guia:

Em qualquer teste que execute código com chamadas HTTP (HTTPRequest, HTTP.send()), o uso de Test.setMock(HttpCalloutMock.class, ...) é obrigatório, mesmo quando a resposta esperada é null, erro ou exceção.

📌 Isso evita:

UnexpectedException por res == null

Falhas de integração simulada

Interrupção do batch/teste silenciosamente

✅ Mocks devem retornar HttpResponse válidos, nunca null diretamente
---


## 🧱 Arquitetura de dados de teste

### 🔹 Orquestradora principal:
```apex
TestDataSetup.setupCompleteEnvironment()
```

Essa classe **não deve conter nenhuma lógica de criação**, apenas chamar:

### 🔸 Módulos `*TestDataSetup.cls` por objeto:

| Classe                        | Responsável por criar           |
|------------------------------|---------------------------------|
| `UserTestDataSetup`          | `User`, `ProfileId`             |
| `AccountTestDataSetup`       | `Account`, `Contact`            |
| `LeadTestDataSetup`          | Todos os tipos de `Lead`        |
| `DistribuidoraTestDataSetup` | `Distribuidora__c`, `Tarifa__c` |
| `GeradorTestDataSetup`       | `Gerador__c`, `Veiculo__c`, `Produto__c` |
| `VerticalTestDataSetup`      | `Vertical__c`                   |
| `OriginadorTestDataSetup`    | `Originador__c`, filho ou pai   |
| `OpportunityTestDataSetup`   | `Opportunity`                   |
| `PropostaTestDataSetup`      | `Proposta__c`                   |
| `UcTestDataSetup`            | `UC__c`, `Contrato_de_Adesao__c`|
| `CobrancaTestDataSetup`      | `Cobranca__c`                   |
| `DocumentoTestDataSetup`     | Todos os `Documento__*__c`      |
| `SignatarioTestDataSetup`    | `Signatario_do_Gerador__c`, `Signatario_da_Oportunidade__c` |
| `CaseTestDataSetup`          | `Case`                          |

---

## 🚫 Proibições absolutas

| Sintaxe / prática                 | Status      |
|----------------------------------|-------------|
| `System.debug(...)`              | ❌ PROIBIDO |
| `LoggerContext.getLogger().log(...)` com menos de 11 parâmetros | ❌ PROIBIDO |
| `TestDataSetup` contendo lógica de criação | ❌ PROIBIDO |
| Misturar objetos em `*TestDataSetup.cls` (ex: `Lead` em `AccountTestDataSetup`) | ❌ PROIBIDO |
| Safe navigation `obj?.field`     | ❌ Apex não suporta |
| Operadores `??` e `?:`           | ❌ Apex não suporta |
| `var` como tipo de variável      | ❌ Apex exige tipo explícito |

---

## 🧾 Checklist de revisão

- [ ] Cada classe `*TestDataSetup` contém apenas 1 objeto
- [ ] Logging 100% via `LoggerHelper` ou `ILogger` completo
- [ ] Testes usam `LoggerMock` com `LoggerContext.setLogger(...)`
- [ ] Nenhum `System.debug()` existe no código fora de `LoggerMock`
- [ ] `TestDataSetup` só orquestra, não cria registros diretamente

---

✅ **Esse guia é obrigatório para todo PR com testes unitários, batchs, triggers, flows e agendamentos.**
```

---
