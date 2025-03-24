# 📘 Guia Rigoroso de Revisão Apex

📎 Consulte também os demais guias complementares:
- 📄 [Guia de Testes Apex](https://bit.ly/GuiaTestsApex)
- 🧪 [Guia de Logger + LoggerContext](https://bit.ly/GuiaLoggerApex)
- 🔁 [Template de Comparação Antes vs Depois](https://bit.ly/ComparacaoApex)
- 🧱 [Classe TestDataSetup Central](https://bit.ly/TestDataSetup)
- ✅ [Confirmação de Equivalência Funcional](https://bit.ly/ConfirmacaoApex)

---

## ✅ Objetivo
Estabelecer **padrões inegociáveis** para revisão, escrita, refatoramento e logging de código Apex, com foco em:
- Previsibilidade
- Padrão organizacional
- Auditação de logs
- Testabilidade

---

## ⚖️ Regras Absolutas

### 1. Logger obrigatório
- Proibido `System.debug()` (exceto em testes com `LoggerMock`)
- Sempre usar: 
```apex
LoggerContext.getLogger().log(...);
```

### 2. Controle de contexto
Toda classe Apex **deve conter no topo**:
```apex
@TestVisible private static String environment = Label.ENVIRONMENT;
@TestVisible private static String log_level = Label.LOG_LEVEL;
private static final String className = '<NOME_DA_CLASSE>';
private static final String triggerType = '<REST | Batch | Trigger | Apex>';
private static final String logCategory = '<API | Service | Apex | etc>';
```

### 3. Refatorar com equivalência funcional
- Toda refatoracao **deve incluir**:
  - ✅ Novo código completo
  - ✅ Tabela comparativa Antes vs Depois ([Template](https://bit.ly/ComparacaoApex))
  - ✅ Confirmação de equivalência funcional ([Checklist Final](https://bit.ly/ConfirmacaoApex))

### 4. Testes obrigatórios
- Usar `TestDataSetup.setupCompleteEnvironment()`
- Desabilitar flows com `FlowControlManager.disableFlows()`
- ❌ **Não usar `System.enqueueJob()` diretamente:** simular com `LoggerMock`
- ⚠️ **Não validar logs gerados nos testes**, pois `LoggerQueueable` é assíncrono

### 5. Sintaxes proibidas
| Proibido 🚫                        | Motivo ❌ |
|-----------------------------------|-----------|
| `obj?.campo`                      | Safe nav. não suportado em Apex |
| `var`                             | Apex exige tipo explícito |
| `??`                              | Coalescência não existe em Apex |
| `log => log.contains(...)`        | Arrow functions não existem |
| `list.anyMatch(...)`              | não suportado |

### 6. Métodos internos @TestVisible
- Todos os métodos internos devem ser anotados com `@TestVisible`
- Os métodos devem ser escritos com parâmetros de entrada simples e simuláveis
- Objetivo: facilitar cobertura completa e segura durante os testes

---

## 🗃️ Modelo padrão de log
```apex
LoggerContext.getLogger().log(
    Logger.LogLevel.INFO,
    className,
    methodName,
    triggerRecordId,
    'Mensagem de contexto',
    detalheTecnico,
    stackTrace,
    dadosSerializados,
    triggerType,
    logCategory,
    environment
);
```

> ✊ Sugestão: criar `logInfo(...)` e `logError(...)` como wrappers internos

---

## 🧰 Checklist de Revisão
- [ ] Classe usa `LoggerContext.getLogger()`?
- [ ] Variáveis de controle estão no topo?
- [ ] Testes usam `LoggerMock`?
- [ ] Nenhum uso de `System.debug()`?
- [ ] **Não usa `enqueueJob()` diretamente nos testes**?
- [ ] Usa `TestDataSetup.setupCompleteEnvironment()`?
- [ ] Fluxos desabilitados com `FlowControlManager.disableFlows()`?
- [ ] ⚠️ Não tenta validar logs de LoggerQueueable?
- [ ] Refatorou com comparação Antes vs Depois?
- [ ] Métodos internos estão anotados com `@TestVisible`?

---

## 📄 Apêndice: Padrões para classes de teste
- Nome da classe deve terminar com `Test`
- Usar `@isTest`, `@TestSetup`, e `Test.startTest()` / `Test.stopTest()` corretamente
- Logs devem ser simulados com `LoggerMock`, **não validados diretamente**
- Incluir cenários:
  - Positivo (happy path)
  - Negativo (validação de erros)
  - Exceção (falhas intencionais)

---

## ⚙️ Apêndice: Boas práticas sugeridas
- Criar classes `XTestDataSetup` por objeto (ex: `UsinaTestDataSetup`)
- Centralizar testes com dados reutilizáveis
- Evitar `seeAllData=true` sempre que possível
- Tornar métodos testáveis por design, com assinatura simples e pública ou `@TestVisible`

---

> ⭐ Versão 2025 com ajustes baseados em revisões reais via Apex Revisor Rigoroso
