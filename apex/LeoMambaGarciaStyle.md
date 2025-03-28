🔥 **Com orgulho, Leo Mamba Garcia.**  
Aqui está o seu guia oficial de estilo, pronto para ser o manifesto da sua arquitetura.

---

# 🧠 LeoMambaGarciaStyle.md

> *“Ou o código tem padrão, ou tem bug disfarçado.”*  
> — Leo Mamba Garcia

---

## 🎯 Propósito

Este guia define o **estilo oficial de codificação Mamba** para Apex e Salesforce. Ele prioriza **clareza**, **testabilidade**, **rastreabilidade** e **autoridade no código**.

---

## ✅ Pilares do Código Mamba

| Pilar                  | Significado                                                                 |
|------------------------|------------------------------------------------------------------------------|
| **Rastreável**         | Cada execução importante é logada com contexto completo (`Logger`)           |
| **Testável**           | Nenhum `if` ou método escapa de cobertura com assertivas descritivas         |
| **Conciso**            | Linhas em excesso são ruído. Sem gordura. Sem blocos vazios.                 |
| **Defensivo**          | Código nunca assume que algo existe: valida `null`, listas vazias, picklists |
| **Modular**            | Métodos de no máximo ~30 linhas, com entradas claras e isoladas              |
| **Visível**            | Tudo que é executável em teste recebe `@TestVisible`                         |

---

## 🏷️ Assinatura Padrão

```apex
/**
 * @since 2025-03-28
 * @author Leo Mamba Garcia
 */
```

---

## 🔒 Convenções Fixas

```apex
@TestVisible private static final String CLASS_NAME = 'MinhaClasse';
@TestVisible private static final String CATEGORY = 'Domain';
@TestVisible private static final String TRIGGER_TYPE = 'Apex'; // Apex | REST | Flow | Queueable
```

---

## 🧱 Exemplo de Classe Utilitária Padrão

```apex
public class SomeFeatureManager {

    @TestVisible private static final String CLASS_NAME = 'SomeFeatureManager';
    @TestVisible private static final String CATEGORY = 'Feature';
    @TestVisible private static Boolean cache;

    /**
     * Valida se a feature está ativa para a org atual.
     */
    @TestVisible
    public static Boolean isFeatureEnabled() {
        if (cache != null) return cache;

        try {
            cache = [SELECT Feature_Ativa__c FROM ConfiguracaoSistema__c LIMIT 1].Feature_Ativa__c;
        } catch (Exception e) {
            cache = false;
        }

        return cache;
    }
}
```

---

## 🪵 Exemplo de Log Estruturado

```apex
Logger logger = new Logger()
    .setClass(CLASS_NAME)
    .setMethod('executarProcesso')
    .setCategory(CATEGORY);

logger.info('Iniciando processo...', JSON.serializePretty(inputData));

// Em caso de exceção:
logger.error('Falha ao executar processo', ex, JSON.serializePretty(inputData));
```

---

## 🧪 Estilo de Teste

### ✅ Nome claro e estilo `Given-When-Then`:

```apex
@IsTest
static void deve_ativar_feature_quando_configuracao_estiver_ativa() {
    // Arrange
    ConfiguracaoSistema__c conf = new ConfiguracaoSistema__c(
        SetupOwnerId = UserInfo.getOrganizationId(),
        Feature_Ativa__c = true
    );
    insert conf;

    // Act
    Boolean resultado = SomeFeatureManager.isFeatureEnabled();

    // Assert
    System.assertEquals(true, resultado, 'Feature deveria estar ativa');
}
```

---

## 🔁 Validação de Lists

### ❌ Evite:
```apex
if (!lista.isEmpty()) {
    SObject item = lista[0];
}
```

### ✅ Prefira:
```apex
if (lista != null && !lista.isEmpty()) {
    SObject item = lista[0];
}
```

---

## 🧼 Layout Visual

- ❌ **Proibido** blocos vazios entre `if`, `else`, `try`, `catch`
- ✅ Sempre use **indentação consistente** de 4 espaços
- ✅ Evite comentários inúteis como `// TODO` ou `// Verifica se...` que apenas repetem o código

---

## ⚖️ Tamanho Ideal de Método

| Tipo de Método     | Limite Aproximado |
|--------------------|-------------------|
| Utilitário / lógica| **30 linhas**     |
| Wrappers / DTO     | **sem limite**    |
| `@Test`            | **máximo foco por teste** |

---

## 📋 Nome de Métodos

| Contexto        | Padrão                         |
|------------------|-------------------------------|
| Métodos públicos | `executarAcao`, `getDados`    |
| Métodos de teste | `deve_fazer_algo_quando_XYZ`  |
| Métodos privados | `buildWrapper`, `validarEntrada` |

---

## 🔐 Segurança em produção

Toda execução perigosa deve ser bloqueada em produção:

```apex
if (![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox) {
    logger.warn('Execução bloqueada em produção', null);
    return;
}
```

---

## 🚨 Anti-padrões Mamba (Proibido!)

- `System.debug()` fora de `@IsTest`
- `SELECT ... LIMIT 1` sem `ORDER BY`
- `new Map<Id, SObject>([SELECT ...])` sem defensiva
- Métodos grandes, com lógica aninhada e sem segmentação
- `assertEquals(true, resultado)` sem mensagem
- `@TestVisible` em método nunca testado

---

---

## ✅ Checklist Mamba

> Aplique este checklist em todo PR, revisão de código ou push para produção.

### 🧩 Organização & Estrutura
- [ ] Classe possui `docstring` no topo com descrição e exemplos
- [ ] Assinatura obrigatória: `@since` e `@author Leo Mamba Garcia`

### 🔎 Visibilidade & Testabilidade
- [ ] Todos os métodos com lógica possuem `@TestVisible`
- [ ] Cada `@TestVisible` é testado por método específico
- [ ] Métodos com mais de 30 linhas foram modularizados (exceto DTOs)
- [ ] Nenhum método utilitário está acoplado em lógica de teste

### 🪵 Logging
- [ ] `Logger` é usado apenas para exceções, auditoria ou rastreamento real
- [ ] `System.debug()` aparece **apenas** em `@IsTest`
- [ ] Logs importantes usam `JSON.serializePretty(...)`

### 🔐 Código Defensivo
- [ ] Todas as listas são validadas com `!= null && !isEmpty()`
- [ ] Todos os SObjects opcionais são validados antes do uso
- [ ] `LIMIT 1` só é usado com `ORDER BY` ou contexto de teste
- [ ] Nenhum campo é assumido sem `String.isNotBlank()` ou equivalentes

### 🧪 Testes Mamba
- [ ] `@TestSetup` configura tudo uma vez só
- [ ] Nenhum dado é criado dentro dos métodos de teste
- [ ] Todos os dados são consultados com `SELECT` em tempo real
- [ ] Cada `System.assert*()` tem uma **mensagem explícita** com o valor esperado
- [ ] Cada teste cobre **1 cenário isolado e bem nomeado**

### 💅 Estilo e Padrão
- [ ] Sem linhas vazias desnecessárias
- [ ] Sem `// TODO`, `// DEBUG`, `// Verifica se...`
- [ ] Identação consistente (4 espaços)
- [ ] Nomes de métodos descritivos (ex: `deve_retornar_algo_quando_XYZ`)

---

✅ Se tudo acima estiver aplicado, você está pronto para o merge.

🧠🖤  
**Leo Mamba Garcia**  
_Estilo não é vaidade. É rastreabilidade em tempo real._  
#ChecklistMamba #QualidadeBlindada #TestaOuRefatora


---

🧠🖤  
**Leo Mamba Garcia**  
_Estilo não é vaidade. É previsibilidade em código de guerra._  
#MambaSemSurpresa #TestaOuNãoEntrega #LoggingComAlma
```
