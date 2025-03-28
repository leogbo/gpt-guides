# 🧱 **Guia Oficial Mamba Apex Revisor**  
**Estilo: Mamba Mentality. Excelência Intransigente.**  
📎 **Shortlink oficial:** [bit.ly/GuiaApexMamba](https://bit.ly/GuiaApexMamba)

> **"Excelência não é uma opção, é uma exigência."** – Mamba Mentality 🧠🔥

Este guia contém os **padrões absolutos** para criação, refatoração e teste de código em **Salesforce Apex**, com o objetivo de manter uma **qualidade, rastreabilidade e consistência intransigentes** em todos os processos da sua Org.  
O conceito central do **Mamba Apex** é garantir que **nada menos que o melhor** será aceito, com rigor, foco e **sem espaço para códigos meia-boca**.

---

## 🎯 **Missão**  
Garantir **qualidade, estabilidade, performance e rastreabilidade absoluta** em cada linha da sua Org.  
Refatoramos quantas vezes forem necessárias até atingir **excelência funcional e estrutural total**.  

---

## 🧩 **Fundamentos da Mentalidade Mamba**

### **O que é Mamba Mentality?**
> **"O sucesso é construído sobre o compromisso com a excelência e a eliminação de qualquer fraqueza."**

Mamba Mentality é sobre **não aceitar menos**. Não importa se o código "funciona", se ele **não é rastreável, testável e perfeito**, ele não será aceito. Aqui, buscamos resultados excepcionais.  
**Mamba Mentality** não é só sobre a **qualidade do código**. É sobre **responsabilidade** na criação, **rastreabilidade** nas mudanças e **rigor** no desenvolvimento.

---

## 🛠️ **Padrões de Código (Mamba Style)**

- **Visibilidade e Testabilidade**: Todos os métodos com lógica devem ser marcados com `@TestVisible` e testados com cobertura de 100%. Se algo não pode ser testado, ele não pertence à produção.
- **Segurança e Consistência**: Usamos sempre **`RestServiceHelper`** para todas as respostas de API, nunca um código improvisado.
- **Logs Estruturados**: **`LoggerContext`** e **`FlowExecutionLog__c`** são obrigatórios para rastreamento completo.
- **Sem Exceções sem Rastreamento**: Cada exceção deve ter um log claro com rastreabilidade e uma mensagem específica.

---

## ✅ **Checklists e Requisitos**

### **Padrão de Estrutura de Classe:**
1. **Classe e Docstring**: A classe deve ter uma **descrição no topo** explicando sua finalidade e incluindo exemplos práticos de uso.
2. **`@TestVisible`**: Cada método lógico deve ser **testável** e ter cobertura com asserts claros.
3. **Uso de `LoggerContext.getLogger().log(...)`**: A única maneira de **logar** é através do **Logger**, sem exceções.

---

## 🧪 **Testes de Alta Qualidade**  
Apenas testes **robustos e claros** são aceitos. O código deve ser **testado de forma isolada** e **mapeado** em cada cenário possível.

### **Testes Obrigatórios para APIs REST**:
- **@IsTest** com **@TestSetup** que cria registros reais (Lead, Account, etc.).
- **Mocks** para chamadas externas se houver (`HttpCalloutMock`).
- **LoggerMock** aplicado para rastreabilidade de logs.
- Teste de **happy path**, **bad request**, e **not found**.

> Lembre-se: **Testes não são apenas uma formalidade.** Eles são parte do código e devem seguir os padrões de **rastreabilidade** e **claresa absoluta**.

---

## 📘 **Revisão e Refatoração - A Arte da Mamba**

- **Refatoração contínua** até o código alcançar a **excelência imbatível**.
- **Comparativo de antes e depois** via [ComparacaoApex](https://bit.ly/ComparacaoApex) é obrigatório.
- **Confirmação de equivalência funcional** via [ConfirmacaoApex](https://bit.ly/ConfirmacaoApex).
- **Nada é aceitável se não estiver em conformidade com os guias** de **estilo** e **qualidade**.

---

## 📄 **Fluxo de Refatoração Mamba**

1. **Novo código revisado** segundo os guias (sempre em conformidade com https://bit.ly/LeoMambaGarciaStyle).
2. **Comparativo Antes vs Depois** → [ComparacaoApex](https://bit.ly/ComparacaoApex).
3. **Confirmação funcional** → [ConfirmacaoApex](https://bit.ly/ConfirmacaoApex).
4. **Testes atualizados** conforme → [GuiaTestsApex](https://bit.ly/GuiaTestsApex).
5. **Logging via** `LoggerContext.getLogger().log(...)`.
6. **Setup de dados via** `TestDataSetup.setupCompleteEnvironment()`.

---

## 🧱 **Padrões de Arquitetura Mamba** (Exemplos e Detalhamento)

- **Estrutura de Classe**:
```apex
@TestVisible private static final String className   = 'MinhaClasse';
@TestVisible private static final String logCategory = 'Domínio';
@TestVisible private static final String environment = Label.ENVIRONMENT;
private static final String triggerType = 'Service | Trigger | Batch | Queueable';
```

- **Logger de Exceções**: Nunca use `System.debug()`. O uso de `FlowExecutionLog__c` e `LoggerContext` é obrigatório:
```apex
LoggerContext.getLogger()
    .setMethod('nomeMetodo')
    .setRecordId(obj.Id)
    .error('Falha crítica', e, JSON.serializePretty(obj));
```

- **JSON e Serialização**: 
```apex
JSON.serializePretty(obj); // Para logs e respostas, nunca use logs truncados.
```

---

## 🧠 **Mentalidade Mamba no Desenvolvimento e Refatoração**

1. **Rigor absoluto** na revisão de código e testes.
2. **Cada método deve ser testado de forma isolada**.
3. **Nunca comprometer a rastreabilidade** ou a **clareza** do código, mesmo em situações de prazo apertado.
4. **Documentação clara e explícita** com exemplo de uso, de forma a nunca deixar dúvidas para quem revisar ou consumir o código.
5. **Refatoração constante** até que o código atinja um nível que possa ser comparado a uma máquina bem calibrada.

---

## 🚀 **Compromissos Imutáveis - A Mentalidade Mamba**

> "A única falha que você pode ter é a falta de vontade de ser excelente." – Mamba Mentality

### **Para cada PR, Trigger ou REST:**
- **Revisão rigorosa** e **acurada** dos requisitos de rastreabilidade, sem tolerância a exceções.
- **Cada linha de código é auditada** com precisão cirúrgica.
- **Cada assert é único**, abrangente e expressivo.
- **Refatoração** só termina quando o código é completamente imbatível.

---

## 📌 **Apexs de Qualidade**

- **Não entregamos código improvisado**, entregamos **código rastreável** e **perfeito**.
- **Não validamos logs via `LoggerMock.getLogs()`**, apenas utilizamos `LoggerMock` para **neutralizar efeitos colaterais**.
- **Testes não são apenas "padrões"**, eles são uma **parte do código** e devem ser auditados com a mesma dedicação.

---

## 🧱 **Mentalidade e Conduta:**

O objetivo é **criar um código sem falhas**, sem desculpas e sem atalhos. Só o melhor, sempre.  
**Mentalidade Mamba** é sobre **a busca implacável pela excelência**.

> **"Não aceitamos código que "funciona". Aceitamos código que é perfeitamente rastreável, imbatível e claro."**

- Refatoração até a perfeição.
- Testes e logs que denunciam falhas antes que aconteçam.
- Código limpo, sem exceções e sem espaços para dúvidas.

---

🧠🖤 **Seja Mamba. Seja Mamba Mentality.**

#APIMamba #MambaMentality #ExcecaoComRastreabilidade #MambaApex
