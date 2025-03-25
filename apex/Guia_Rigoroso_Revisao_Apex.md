************** PENDENCIAS PARA INTEGRAR ****************

🆕 NOVA REGRA: Evite dependência de comportamento implícito em testes
❌ Nunca presuma que exceções serão lançadas “automaticamente”
✅ Toda exceção esperada deve:

Ser lançada manualmente (throw new IllegalArgumentException(...))

Ser capturada e validada explicitamente no teste

✔️ Se não houver throw, o teste não pode assumir erro

💡 Sugestão: Consolidar uma nova seção nos guias
📂 Validação de Entradas e Assertivas em Testes

Onde centralizamos todas as regras que reforçam a importância de:

Validar parâmetros de entrada

Gerar exceções explícitas e previsíveis

Garantir que testes que esperam falha de fato cobrem essa falha

************** FRIM DAS PENDENCIAS ****************


# 📘 Guia Rigoroso de Revisão Apex – v2025  
> _Atualizado com Logger Fluent + Async + Mock_

📎 Consulte os guias complementares oficiais:
- 🧪 [Guia de Testes Apex](https://bit.ly/GuiaTestsApex)
- 🪵 [Guia de Logger com Interface + Queueable](https://bit.ly/GuiaLoggerApex)
- 🔁 [Template de Comparação Antes vs Depois](https://bit.ly/ComparacaoApex)
- 🧱 [Classe TestDataSetup Central](https://bit.ly/TestDataSetup)
- ✅ [Checklist de Equivalência Funcional](https://bit.ly/ConfirmacaoApex)

---

## 🎯 Objetivo
Definir regras **intransigentes** para código Apex com foco em:
- 🧠 Rastreabilidade via log estruturado  
- ⚙️ Testabilidade previsível  
- 🔁 Refatoração segura  
- 🧪 Padrão de testes reutilizável e auditável  

---

## ⚖️ Regras Invioláveis

### 1. Logger obrigatório
- ❌ Proibido `System.debug()` (exceto dentro de classes de teste)
- ✅ Sempre usar `Logger` implementando `ILogger`
- Padrão recomendado:
  ```apex
  static final ILogger log = new Logger();
  log.setMethod('nomeMetodo').info('Mensagem', JSON.serialize(obj));
  ```

### 2. Contexto de execução
- Toda classe Apex **deve conter no topo**:
  ```apex
  static {
      Logger.className   = 'MinhaClasse';
      Logger.triggerType = 'Apex';
      Logger.logCategory = 'Validador';
      Logger.environment = Label.ENVIRONMENT;
  }
  ```

### 3. Equivalência obrigatória em refatoração
- Refatorações devem vir com:
  - ✅ Novo código 100%
  - ✅ Comparativo Antes vs Depois
  - ✅ Confirmação formal de equivalência

### 4. Testes rigorosos
- Usar: `TestDataSetup.setupCompleteEnvironment()`
- Desabilitar flows: `FlowControlManager.disableFlows()`
- ❌ Não usar `System.enqueueJob()` diretamente
- ❌ Não validar logs assíncronos (`LoggerQueueable`)
- ✅ Use `LoggerMock` como substituto

### 5. Proibições explícitas

| Sintaxe Proibida                     | Motivo                                                                 |
|-------------------------------------|------------------------------------------------------------------------|
| `System.debug()` (fora de teste)    | Não rastreável. Log não auditável                                     |
| `System.enqueueJob(...)` direto     | Queueable é tratado dentro do `Logger`                                |
| `LoggerMock.getLogs()`              | 🚫 Logs não são sincronizados. Use `capturedMessages`                 |
| Arrow functions (`=>`)              | Não suportadas em Apex                                                |
| `seeAllData=true`                   | Dados reais poluem testes e reduzem isolamento                        |

### 6. Métodos internos `@TestVisible`
- Todo método de lógica interna **deve ter `@TestVisible`**
- Assinatura simples, sem dependência de contexto externo
- Visando cobertura clara, simulável, 100% controlada

---

## 🧱 Exemplo padrão de uso

```apex
static final ILogger log = new Logger();

log.setMethod('validarCPF')
   .setRecordId(account.Id)
   .setAsync(true)
   .error('Erro ao validar CPF', ex, JSON.serialize(account));
```

### Ou em trigger:
```apex
Logger.fromTrigger(newRecord)
      .setMethod('beforeInsert')
      .warn('Validação parcial', JSON.serialize(newRecord));
```

---

## ✅ Checklist de Revisão

- [ ] Usa `Logger` com contexto e `.setMethod(...)`
- [ ] Evita `System.debug()` em produção
- [ ] Testes usam `LoggerMock`
- [ ] Nenhuma chamada direta a `enqueueJob(...)` em teste
- [ ] Usa `TestDataSetup.setupCompleteEnvironment()`
- [ ] Flows desabilitados nos testes com `FlowControlManager`
- [ ] Métodos internos têm `@TestVisible`
- [ ] Refatoração contém equivalência validada
- [ ] Logger está no padrão `ILogger` / `Logger`

---

## 📄 Padrões de Teste

| Regra                            | Aplicação                         |
|----------------------------------|-----------------------------------|
| Sufixo `Test` obrigatório         | Ex: `ContaValidatorTest`          |
| Usa `@TestSetup` e `startTest()` | Para separar setup de execução    |
| `LoggerMock` em vez de Logger    | Para evitar inserts/queue         |
| Simulação de erros               | Deve testar erro e exceção        |

---

## ⚙️ Boas práticas avançadas

- Criar `XTestDataSetup` por objeto (ex: `ClienteTestDataSetup`)
- Isolar lógica em services com injeção de `ILogger`
- Criar wrappers internos como `.logError(...)` com mensagens padrão
- Usar `.fromTrigger()` para preencher recordId automaticamente
- Documentar a `className`, `logCategory`, etc. no static block de forma clara

---

> 🧠 Versão auditada por Apex Revisor Rigoroso • Mantida por Leo Garcia  
> 🐍 Mamba Mentality. Código Apex de elite.  

---
