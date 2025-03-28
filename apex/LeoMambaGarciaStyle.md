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

## ✅ Checklist Mamba (resumo)

- [ ] `@TestVisible` aplicado em todos os métodos testáveis
- [ ] `Logger` usado apenas em exceções ou contexto crítico
- [ ] Todos os métodos `@TestVisible` cobertos por teste
- [ ] Cada assert tem uma mensagem explícita
- [ ] Nenhum método ultrapassa 30 linhas (exceto DTOs/wrappers)
- [ ] Código defensivo: `null`, `isEmpty()`, validações
- [ ] Sem blocos vazios e sem `System.debug()` fora de teste

---

🧠🖤  
**Leo Mamba Garcia**  
_Estilo não é vaidade. É previsibilidade em código de guerra._  
#MambaSemSurpresa #TestaOuNãoEntrega #LoggingComAlma
```
