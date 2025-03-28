# 🧱 Guia Master de Arquitetura Apex Mamba

> Este é o guia principal e centralizador de **todos os padrões institucionais Apex da sua org**.

📎 **Shortlink oficial:** [bit.ly/GuiaApexMamba](https://bit.ly/GuiaApexMamba)

> “Exige-se excelência. Código não é só código – é rastreabilidade, clareza e poder.” – Mentalidade Mamba 🧠🔥

---

## 📚 Referência Cruzada com Guias Oficiais

| Área                      | Guia Oficial                                                    |
|---------------------------|------------------------------------------------------------------|
| 🔍 Revisão de Código       | [bit.ly/GuiaApexRevisao](https://bit.ly/GuiaApexRevisao)         |
| 🧪 Testes Unitários        | [bit.ly/GuiaTestsApex](https://bit.ly/GuiaTestsApex)             |
| 🩵 Logger e Log Persistente| [bit.ly/GuiaLoggerApex](https://bit.ly/GuiaLoggerApex)           |
| 🧱 Setup de Dados de Teste | [bit.ly/TestDataSetup](https://bit.ly/TestDataSetup)             |
| 🔄 Comparações de Código   | [bit.ly/ComparacaoApex](https://bit.ly/ComparacaoApex)           |
| ✅ Equivalência Funcional  | [bit.ly/ConfirmacaoApex](https://bit.ly/ConfirmacaoApex)         |
| 🌐 APIs REST & JSON        | [bit.ly/Guia_APIs_REST](https://bit.ly/Guia_APIs_REST)           |
| 🧾 Logs de Flows e Auditoria| [bit.ly/FlowExecutionLog](https://bit.ly/FlowExecutionLog)       |

> ✅ Este guia se conecta a todos os outros e deve ser revisitado a cada refatoração, revisão ou criação de novo padrão.

---

## ✅ Mentalidade Mamba (Sempre Ativa)

- **Não aceitamos código que “funciona”. Aceitamos código que é rastreável.**
- **Não entregamos testes que “passam”. Entregamos testes que denunciam falhas.**
- **Refatoração não termina na primeira melhoria. Só termina quando é irrefutavelmente melhor.**
- **Checklist não é burocracia. É disciplina Mamba.**

> 🧠 “Tudo o que você faz deve ser deliberado e rastreável. Inclusive o que você apaga.”

---

## 🧱 Estrutura do Guia Master

### ✅ Capítulo 1: Estrutura de Classe Apex

- Toda classe deve conter os seguintes blocos:
```apex
@TestVisible private static final String className   = 'MinhaClasse';
@TestVisible private static final String logCategory = 'Domínio';
@TestVisible private static final String environment = Label.ENVIRONMENT;
private static final String triggerType = 'Service | Trigger | Batch | Queueable';
```

### ✅ Capítulo 2: Logger como ferramenta de rastreabilidade

- Nunca usar `System.debug()` fora de testes unitários
- `FlowExecutionLog__c` é obrigatório em:
  - REST APIs
  - Triggers
  - Integrações
  - Lógica de negócio de alto impacto
- Exemplo correto:
```apex
Logger logger = new Logger()
    .setClass(className)
    .setMethod('executar')
    .setCategory(logCategory);

logger.error('Falha crítica ao processar registro', e, JSON.serializePretty(input));
```

> 📘 Veja [GuiaLoggerApex](https://bit.ly/GuiaLoggerApex) para padrão completo.

### ✅ Capítulo 3: JSON & Serialização

- Sempre usar `JSON.serializePretty()` para logs e responses
- Nunca logar JSON parcial ou truncado
- Exceções só se o campo for muito pesado e afetar o log

### ✅ Capítulo 4: `RecordHelper.getById(...)` com fallback

- Substitui qualquer `SELECT ... WHERE Id = :id LIMIT 1` sem fallback
- Exemplo correto:
```apex
Account acc = (Account) RecordHelper.getById(Account.SObjectType, id, 'Id, Name');
```
- Evita `System.QueryException: List has no rows for assignment to SObject`

---

## ✅ Capítulo 5: TestHelper – Utilitário Oficial

Classe base para geração de dados simulados, validações internas e IDs controlados para testes negativos.

> 📘 Veja implementação completa: `TestHelper.cls`

### Exemplos de uso:
```apex
Id idInvalido = TestHelper.fakeIdForSafe(UC__c.SObjectType);
String emailFalso = TestHelper.randomEmail();
String telefone = TestHelper.fakePhone();
```

### Forçando falha por ausência de setup:
```apex
List<Account> accs = [SELECT Id FROM Account];
if (accs.isEmpty()) {
    TestHelper.assertSetupCreated('Account');
}
```
> 💡 Evita `null pointer`, `System.QueryException` e dados ambíguos.

---

## 🔁 Capítulo 6: Evite Erros Comuns de Sintaxe Apex vs Java

| Erro Comum       | Correto em Apex                      | Errado (Java Style)        |
|------------------|---------------------------------------|-----------------------------|
| Substring de Id  | `String.valueOf(id).substring(...)`   | `id.substring(...)`         |
| Regex match      | `Pattern/Matcher` do `java.util.regex`| `string.matches(...)`       |
| `%` (módulo)     | `Math.mod(a, b)`                      | `a % b`                     |
| String padding   | `manual + concat` ou `String.format()`| `padLeft` / `padRight`      |

---

## ✅ Capítulo 7: Checklists Obrigatórios

### ✔️ Checklist para nova classe:
- [ ] Possui `@TestVisible` e `triggerType`
- [ ] LogCategory definido
- [ ] Logger estruturado (`LoggerContext` ou `FlowExecutionLog__c`)
- [ ] Teste com cobertura real
- [ ] Método com responsabilidade única

### ✔️ Checklist de refatoração:
- [ ] Antes vs Depois documentado ([ComparacaoApex](https://bit.ly/ComparacaoApex))
- [ ] Confirmada equivalência funcional ([ConfirmacaoApex](https://bit.ly/ConfirmacaoApex))
- [ ] Selects defensivos adicionados
- [ ] `RecordHelper.getById()` aplicado
- [ ] Testes atualizados e rastreáveis

---

## ✅ Capítulo 8: Exemplo de Padrão Completo Mamba

```apex
public class ProdutoService {
    @TestVisible private static final String className   = 'ProdutoService';
    @TestVisible private static final String logCategory = 'Produto';
    @TestVisible private static final String environment = Label.ENVIRONMENT;
    private static final String triggerType = 'Service';

    public static Produto__c buscarProduto(String id) {
        return (Produto__c) RecordHelper.getById(
            Produto__c.SObjectType,
            id,
            'Id, Nome__c, Codigo__c'
        );
    }
}
```

---

## ✅ Capítulo 9: Logger + TestHelper no Ciclo Mamba

Todo teste com exceção controlada deve usar o padrão:

```apex
@TestVisible private static Boolean exceptionThrown = false;

// No método original
if (Test.isRunningTest()) exceptionThrown = true;
```

No teste:
```apex
Test.startTest();
ClasseAlvo.metodoExecutado();
Test.stopTest();
System.assert(ClasseAlvo.exceptionThrown, 'Exceção esperada não foi sinalizada.');
```

Isso garante **testes de endpoints que convertem exceções sem lançar diretamente**, como handlers REST.

---

## 🧠 Final

> Revisar este guia é obrigatório antes de qualquer:
> - Pull Request
> - Refatoração
> - Aprovação de PR de terceiros
> - Geração de novos padrões institucionais

🧠🧱🧪 #MentalidadeMamba #RefatoracaoComRaiz #GuiaCentralSempreAtualizado

---

