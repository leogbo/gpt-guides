# 📌 Guia Rigoroso para Revisão e Refatoração de Código Apex

⚠ **ATENÇÃO: ESTE GUIA DEVE SER SEGUIDO SEM EXCEÇÕES.**  
⚠ **QUALQUER DESVIO DAS REGRAS ESTABELECIDAS AQUI SERÁ CONSIDERADO UM ERRO NA REVISÃO.**  
⚠ **AO RESPONDER UM CÓDIGO, SEMPRE USE A LOUSA, LIMPA ANTES DE ESCREVER A RESPOSTA.**

---

## 🔥 Objetivo

A revisão de código Apex deve ser **completa, detalhada e segura**, garantindo **consistência, compatibilidade e conformidade** com as melhores práticas.

O código revisado **NÃO PODE**:
- Alterar a funcionalidade original
- Remover métodos existentes
- Ser entregue incompleto, inconsistente ou com lógica alterada

---

## 🔒 Regras Essenciais

### 1️⃣ Variáveis de Controle no Início do Código

Todo código deve iniciar com o seguinte bloco de variáveis padrão:

```apex
@TestVisible private static String environment = Label.ENVIRONMENT;
@TestVisible private static String log_level = Label.LOG_LEVEL;
@TestVisible private static Integer MAX_DEBUG_LENGTH = 3000;
private static final String className = '{{nome_da_classe}}';
private static final String triggerType = '{{tipo}}';
private static final String logCategory = '{{categoria}}';
```

---

### 2️⃣ Preservação Absoluta dos Métodos

✅ Nenhum método original pode ser removido ou renomeado  
✅ A assinatura dos métodos **NÃO PODE SER ALTERADA**  
✅ Todos os métodos devem permanecer após refatoração  
✅ Faça validação de consistência antes de entregar

---

### 3️⃣ Modularização Controlada

✅ Criar métodos auxiliares **apenas quando necessário**  
✅ Evitar duplicação de código  
✅ Nunca remover ou fundir métodos existentes

---

### 4️⃣ Garantia de Compatibilidade

✅ Verificar se métodos chamados realmente existem  
✅ Nunca quebrar dependências externas  
✅ Documentar mudanças que impactem outras classes

---

### 5️⃣ Lista de Métodos Antes e Depois da Refatoração

✅ Antes: listar todos os métodos da versão original  
✅ Depois: garantir que todos ainda existem e funcionam

---

### 6️⃣ Código Sempre Completo e Utilizável

✅ O código revisado deve ser entregue de forma integral  
✅ Nenhuma omissão de métodos, variáveis ou trechos relevantes

---

### 7️⃣ Uso Padronizado de Logs com `ILogger` e `LoggerContext`

Todos os logs devem seguir o padrão abaixo:

```apex
LoggerContext.className   = 'MinhaClasse';
LoggerContext.triggerType = 'Batch';
LoggerContext.logCategory = 'DataProcessing';
LoggerContext.environment = Label.ENVIRONMENT;

LoggerContext.getLogger().log(
    'ERROR',
    'meuMetodo',
    'Erro ao salvar entidade',
    'debug info',
    'stack trace',
    'serialized data'
);
```

✅ Nunca use `System.enqueueJob(new LoggerQueueable(...))` diretamente  
✅ Em testes, o `LoggerMock` será usado automaticamente  
✅ Nunca use `System.debug()` fora de testes

---

### 8️⃣ Padrões para Testes

✅ Sempre usar `TestDataSetup.setupCompleteEnvironment()`  
✅ Testar com `Test.startTest()` e `Test.stopTest()`  
✅ Cobrir todos os caminhos de execução (positivos e negativos)  
✅ Usar `LoggerMock` para capturar e validar logs  
✅ Evitar múltiplos `enqueueJob()` em testes  
✅ Asserts com strings devem ser `equalsIgnoreCase` ou `.toUpperCase()`

---

### 9️⃣ Convenções de Nomenclatura

| Elemento              | Padrão            |
|-----------------------|-------------------|
| Variáveis temporárias | `snake_case`      |
| Constantes            | `UPPER_SNAKE`     |
| Métodos e classes     | `CamelCase`       |
| Booleanos             | `is_ativo`, `has_`|

---

### 🔟 Prevenção de NullPointerException

✅ Sempre validar `null` antes de acessar atributos ou métodos  
✅ Nunca confiar que `Map.get(...)` retorna valor seguro  

```apex
String valor = map.containsKey('chave') && map.get('chave') != null 
    ? String.valueOf(map.get('chave')) 
    : '';
```

---

### 📌 11️⃣ Considerações sobre Testes Assíncronos e LoggerQueueable

✅ Nunca fazer asserts sobre registros no `FlowExecutionLog__c`  
✅ Nunca verificar `enqueueJob()` diretamente  
✅ Em testes, usar:

```apex
if (Test.isRunningTest()) {
    System.debug('Log teste');
} else {
    LoggerContext.getLogger().log(...);
}
```

✅ `LoggerQueueable` deve continuar sendo assíncrono  
✅ Validar mensagens por `LoggerMock.getLogs()`

---

## 🔁 12️⃣ Validação de Equivalência Funcional

### ⚖️ Objetivo

Toda refatoração deve **preservar 100% do comportamento original**:

- Mesmo efeito lógico
- Mesmos dados persistidos
- Mesma resposta REST, JSON, valores, etc.
- Mesmas exceções e logs esperados

---

### ✅ Checklist Obrigatório

| Item | Regra |
|------|-------|
| 🔁 Mesma assinatura de métodos |
| 🔒 Todos os campos manipulados mantidos |
| 🧪 Mesmo tratamento de erro e retorno |
| 📤 Mesmo payload e status de resposta |
| 🧼 Mudança de estilo não pode mudar a lógica |

---

### 📋 Entrega Obrigatória

1. ✅ Bloco com código refatorado  
2. ✅ Tabela "Antes vs Depois"  
3. ✅ Confirmação explícita de equivalência  
4. ✅ Justificativa clara para melhorias estruturais  
5. ❌ Refatorações sem equivalência devem ser recusadas

---

## 🧱 13️⃣ Padrões de Sintaxe e Restrições do Apex

### ❌ Sintaxes Proibidas

| Proibido | Motivo |
|----------|--------|
| `log => log.contains(...)` | Arrow functions (`=>`) não são suportadas |
| `list.anyMatch(...)` | Métodos modernos como `filter`, `map`, `reduce` não existem |
| `System.Test.getAccessibleStaticVariable(...)` | Método não existe |
| `obj?.campo` | Safe navigation (`?.`) não é permitido |
| `??` | Operador de coalescência não existe |
| `var` | Apex não tem inferência de tipo |

---

### ✅ Padrões Corretos

| Situação | Forma recomendada |
|----------|--------------------|
| Verificar item em lista | `for (...) { if (...) ... }` |
| Verificar substring | `stringA.contains('...')` |
| Obter valor de map | `map.containsKey('x') ? String.valueOf(map.get('x')) : ''` |

---

### ✅ Exemplo correto

```apex
Boolean encontrou = false;
for (String log : logger.getLogs()) {
    if (log.contains('Erro')) {
        encontrou = true;
        break;
    }
}
System.assert(encontrou, 'Esperava log de erro.');
```

---

## ✅ Observações Finais

- **Este guia é obrigatório**. Toda revisão ou código novo deve segui-lo.
- Toda lógica de log deve ser feita com `LoggerContext.getLogger()`
- O guia deve ser evoluído com base em casos reais
- Revisões que não seguirem estas diretrizes **devem ser rejeitadas**

---
