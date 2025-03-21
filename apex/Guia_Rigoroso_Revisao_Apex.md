# 📖 Guia Rigoroso de Revisão Apex

---

## ✅ 1. Obediência total ao Guia

- Toda classe Apex **deve seguir este guia na íntegra**
- Nenhuma exceção será aceita, mesmo que o código "funcione"
- Se não estiver 100% em conformidade, **a revisão deve ser recusada**

---

## ✅ 2. Estrutura obrigatória do código

Cada classe Apex deve conter no topo:

```apex
@TestVisible private static String environment       = Label.ENVIRONMENT;
@TestVisible private static String log_level         = Label.LOG_LEVEL;
@TestVisible private static Integer MAX_DEBUG_LENGTH = 3000;
private static final String className   = 'NOME_DA_CLASSE';
private static final String triggerType = 'Apex'; // ou Batch, REST, etc.
private static final String logCategory = 'NomeCategoria';
```

---

## ✅ 3. Uso obrigatório de logs

Todos os logs devem usar:

```apex
LoggerContext.getLogger().log(
    'NIVEL',
    'nomeDoMetodo',
    'Mensagem de log',
    optionalErrorMessage,
    optionalStackTrace,
    optionalSerializedData
);
```

- ❌ `System.debug()` é proibido (exceto em testes)
- ❌ `System.enqueueJob(...)` direto é proibido (ver seção abaixo)
- ✅ Logs devem ser específicos, claros e rastreáveis

---

## ✅ 4. Enfileiramento com log (`LoggerJobManager`)

### 🔒 É **proibido** usar `System.enqueueJob(...)` diretamente.

Para enfileirar qualquer job do tipo `Queueable`, utilize:

```apex
LoggerJobManager.enqueueJob(new MeuQueueable(), recordId);
```

### ✅ Implementação obrigatória:

```apex
public class LoggerJobManager {
    public static void enqueueJob(Queueable job, String recordId) {
        LoggerContext.getLogger().log(
            'INFO',
            'LoggerJobManager.enqueueJob',
            'Enfileirando job da classe: ' + String.valueOf(job),
            recordId,
            null,
            null
        );
        System.enqueueJob(job);
    }
}
```

### ❌ Proibido:

```apex
System.enqueueJob(new MeuJob());                   // ❌ NUNCA
LoggerContext.getLogger().logQueueable(...);       // ❌ Método inexistente
ILogger.logQueueable(...)                          // ❌ Fora do escopo permitido
```

---

## ✅ 5. Testes obrigatórios

- Devem usar:
  - `LoggerMock` para interceptar logs
  - `TestDataSetup.setupCompleteEnvironment()` no `@testSetup`
  - `FlowControlManager.disableFlows()` no `@testSetup`
- Devem validar:
  - Cenários positivos
  - Negativos
  - Com exceção
- Devem usar `LoggerMock.getLogs()` para verificar logs emitidos

---

## ✅ 6. Validação de equivalência funcional

Para qualquer **refatoração solicitada**, a resposta da revisão deve conter:

1. Código final completo
2. Tabela "Antes vs Depois"
3. Garantia de equivalência funcional (sem alteração de comportamento)

📄 Modelo: [bit.ly/ComparacaoApex](https://bit.ly/ComparacaoApex)

---

## 🚨 7. Sintaxes proibidas

As seguintes construções são **estritamente proibidas** no Apex:

| Proibido 🚫                        | Motivo ❌ |
|-----------------------------------|-----------|
| `log => log.contains()`           | Arrow functions não são suportadas |
| `list.anyMatch(...)`              | Collections modernas não existem |
| `System.Test.getAccessible...()`  | Método inexistente |
| `obj?.campo`                      | Safe navigation não suportado |
| `??`                              | Coalescência não existe |
| `var`                             | Apex exige tipo explícito |

📖 Veja: [bit.ly/GuiaApexRevisao](https://bit.ly/GuiaApexRevisao)

---

## ✅ 8. Exemplo de revisão rejeitada corretamente

```markdown
❌ O código fornecido não segue o Guia Rigoroso de Revisão Apex:

- Está usando System.enqueueJob(...) diretamente (proibido)
- Faltam variáveis de controle: className, log_level, etc.
- Nenhum uso de LoggerContext.getLogger().log(...)

📚 Siga o padrão:  
🔗 Guia completo: bit.ly/GuiaApexRevisao  
🧪 Testes obrigatórios: bit.ly/GuiaTestsApex  
📊 Refatorações: bit.ly/ComparacaoApex  
```

---

## 🔁 Links úteis

- [Guia de Testes Apex](https://bit.ly/GuiaTestsApex)  
- [Guia de Logging com LoggerQueueable](https://bit.ly/GuiaLoggerApex)  
- [Comparações de Refatoração](https://bit.ly/ComparacaoApex)  
```
