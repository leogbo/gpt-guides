# 🧱 **Guia Master de Arquitetura Apex Mamba**  

📎 **Shortlink oficial:** [bit.ly/GuiaApexMamba](https://bit.ly/GuiaApexMamba)

> **"Exige-se excelência. Código não é só código – é rastreabilidade, clareza e poder."** – Mentalidade Mamba 🧠🔥

---

## 🧠 **Mentalidade Mamba (Sempre Ativa)**

Mamba Mentality não é apenas sobre **entregar código funcional** – é sobre **perfeição rastreável**, **excelência contínua** e **testes robustos** que **denunciam falhas** antes que elas aconteçam.  
Se você está aqui, você já sabe que cada linha de código é uma oportunidade de **exibir o seu melhor**, sem desculpas, sem atalhos.

---

## 📚 **Referência Cruzada com Guias Oficiais**

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

> ✅ **Este guia se conecta a todos os outros** e deve ser **revisitado** a cada refatoração, revisão ou criação de novo padrão.

---

## ✅ **Mentalidade Mamba: Não Aceitamos Menos que a Perfeição**

**"Não aceitamos código que 'funciona'. Aceitamos código que é perfeito e rastreável."** – Mamba Mentality

### **Padrões Imutáveis:**
- **Refatoração contínua** até que o código seja imbatível.
- **Testes não são opcionais**, são obrigatórios e devem ser sempre **robustos, isolados e auditáveis**.
- **Logs completos e rastreáveis** são uma **necessidade absoluta**, nunca use `System.debug()` no código de produção.
- **Clareza absoluta** no código e nos testes: sem espaço para ambiguidades.

---

## 🧩 **Fundamentos do Guia de Arquitetura Apex**

### ✅ **Capítulo 1: Estrutura de Classe Apex**

- Toda classe deve conter **metadados de rastreabilidade** no topo da classe, incluindo o nome da classe, categoria de log e tipo de trigger:
```apex
@TestVisible private static final String className   = 'MinhaClasse';
@TestVisible private static final String logCategory = 'Domínio';
@TestVisible private static final String environment = Label.ENVIRONMENT;
private static final String triggerType = 'Service | Trigger | Batch | Queueable';
```

### ✅ **Capítulo 2: Logger como Ferramenta de Rastreabilidade**

- **Nunca use `System.debug()` fora de testes unitários**. Em produção, a única forma de logar é através do **LoggerContext**.
- **FlowExecutionLog__c** é **obrigatório** em REST APIs, Triggers, Integrações e Lógicas de Negócio de alto impacto.
```apex
LoggerContext.getLogger()
    .setMethod('nomeMetodo')
    .setRecordId(obj.Id)
    .error('Falha crítica', e, JSON.serializePretty(obj));
```

### ✅ **Capítulo 3: JSON & Serialização**

- **Sempre use `JSON.serializePretty()`** para logs e respostas, nunca logue JSON parcial ou truncado.
- **Exceções** só devem ser usadas quando o campo for **extremamente grande** e afetar o log.

### ✅ **Capítulo 4: `RecordHelper.getById(...)` com Fallback**

- **Nunca use `SELECT ... WHERE Id = :id LIMIT 1`** sem fallback.
- **Uso correto**:
```apex
Account acc = (Account) RecordHelper.getById(
    Account.SObjectType,
    id,
    'Id, Name'
);
```
- Evite o erro `System.QueryException: List has no rows for assignment to SObject`.

---

## ✅ **Capítulo 5: TestHelper – Utilitário Oficial**

- Use **`TestHelper`** para dados simulados (ID, e-mail, telefone).
```apex
Id fakeId = TestHelper.fakeIdForSafe(UC__c.SObjectType);
String email = TestHelper.randomEmail();
String tel = TestHelper.fakePhone();
```
- Use **`fakeIdForSafe(...)`** quando precisar de um ID válido mas **inexistente**.

---

## 🔁 **Capítulo 6: Evite Erros Comuns de Sintaxe Apex vs Java**

| Erro Comum       | Correto em Apex                      | Errado (Java Style)        |
|------------------|---------------------------------------|-----------------------------|
| Substring de Id  | `String.valueOf(id).substring(...)`   | `id.substring(...)`         |
| Regex match      | `Pattern/Matcher` do `java.util.regex`| `string.matches(...)`       |
| `%` (módulo)     | `Math.mod(a, b)`                      | `a % b`                     |
| String padding   | `manual + concat` ou `String.format()`| `padLeft` / `padRight`      |

---

## ✅ **Capítulo 7: Checklists Obrigatórios**

### ✔️ **Checklist para Nova Classe**:
- [ ] **`@TestVisible`** e **`triggerType`** definidos
- [ ] **LogCategory** definido
- [ ] **Logger** estruturado (`LoggerContext` ou `FlowExecutionLog__c`)
- [ ] Teste com **cobertura real** (sem mocks ou dados simulados)
- [ ] Método com **responsabilidade única** (responsabilidade única sempre!)

### ✔️ **Checklist de Refatoração**:
- [ ] **Antes vs Depois** documentado → [ComparacaoApex](https://bit.ly/ComparacaoApex)
- [ ] **Equivalência funcional** confirmada → [ConfirmacaoApex](https://bit.ly/ConfirmacaoApex)
- [ ] **Selects defensivos** adicionados
- [ ] **`RecordHelper.getById()`** aplicado para consultas seguras
- [ ] **Testes atualizados e rastreáveis**

---

## ✅ **Capítulo 8: Exemplo de Padrão Completo Mamba**

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

## 🧠 **Mentalidade Mamba no Desenvolvimento e Refatoração**

- **Não aceitamos código improvisado**, entregamos **código rastreável** e **perfeito**.
- **Refatoração contínua** até o código ser **irrefutavelmente melhor**.
- **Testes não são apenas "padrões"**, são uma **parte do código** e devem ser auditados com a mesma dedicação.
- **Nada é aceitável sem documentação**. Cada classe, método e função devem ser **claramente descritos**.

---

## 📜 **Rastreabilidade e Responsabilidade**

> **“A única falha que você pode ter é a falta de vontade de ser excelente.”** – Mamba Mentality

- **Refatoração contínua** até alcançar a **excelência imbatível**.
- **Testes e logs de alta qualidade** para evitar que falhas passem despercebidas.
- **Sem exceções** no código ou nos testes.

---

🧠🧱 **Seja Mamba. Seja Mamba Mentality.**

#ApexMamba #RefatoracaoComRaiz #RastreabilidadeSempre #MentalidadeMamba #ExcecaoComRastreabilidade
