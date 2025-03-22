# 🧪 Guia Rigoroso de Testes Apex

---

## ✅ 1. Estrutura Mínima Obrigatória

Todo teste **deve conter obrigatoriamente**:

```apex
@TestSetup
static void setupTestData() {
    TestDataSetup.setupCompleteEnvironment();
    FlowControlManager.disableFlows();
}
```

E sempre que houver logging:

```apex
LoggerContext.setLogger(new LoggerMock());
```

---

## 📐 2. Ordem Recomendada no Setup

🔁 Padrão de otimização para testes intensivos
Toda classe *TestDataSetup que consulta registros padrões como RecordType, Profile, Distribuidora, etc., deve usar cache local estático para evitar estouro de limites em testes de carga.

1. `TestDataSetup.setupCompleteEnvironment()`  
2. `FlowControlManager.disableFlows()`  
3. Apenas depois disso: execuções e assertivas  
4. Uso de `Test.startTest()` e `Test.stopTest()` sempre que necessário

---

## 🪵 3. Uso obrigatório de `LoggerMock` nos testes

Todo teste que envolva logs estruturados **deve mockar o logger** com:

```apex
LoggerContext.setLogger(new LoggerMock());
```

### ✅ Verificação dos logs gerados:

```apex
List<String> logs = ((LoggerMock) LoggerContext.getLogger()).getLogs();
Boolean encontrou = logs.any(log => log.contains('createAccount'));
System.assertEquals(true, encontrou, 'Deveria haver log de criação de Account.');
```

> ⚠️ **Proibido** usar `System.debug()` fora de classes de teste!

---

# 📦 CAPÍTULO 4 – Mockagem Rigorosa de `RestRequest` e `RestResponse`

---

## 🎯 Objetivo

Simular com precisão chamadas REST e garantir:

- Isolamento total do contexto HTTP
- Testes robustos para `@RestResource`, `RestServiceHelper`, etc.
- Validação funcional e estrutural do ciclo REST

---

## ✅ 4.1 – Estrutura mínima obrigatória

Todo teste de REST deve conter:

```apex
RestContext.request = new RestRequest();
RestContext.response = new RestResponse();
```

> 🔒 **Proibido omitir `RestContext.response`!**  
> Sem ela, `sendResponse(...)` gera `System.NullPointerException`.

---

## 🧱 4.2 – Exemplo base GET

```apex
RestContext.request = new RestRequest();
RestContext.response = new RestResponse();
RestContext.request.requestURI = '/services/apexrest/minhaapi';
RestContext.request.httpMethod = 'GET';
RestContext.request.addParameter('id', 'a00XXXXXXXXXXXX');
RestContext.request.addHeader('Access_token', Label.BEARER_TOKEN_EXEMPLO);
```

---

## 📦 4.3 – Exemplo base POST com JSON

```apex
Map<String, Object> payload = new Map<String, Object>{ 'campo' => 'valor' };

RestContext.request = new RestRequest();
RestContext.response = new RestResponse();
RestContext.request.requestURI = '/services/apexrest/minhaapi';
RestContext.request.httpMethod = 'POST';
RestContext.request.requestBody = Blob.valueOf(JSON.serialize(payload));
RestContext.request.addHeader('Access_token', Label.BEARER_TOKEN_EXEMPLO);
RestContext.request.addHeader('Content-Type', 'application/json');
```

---

## ⚠️ 4.4 – Cenários obrigatórios

### 🔐 Token inválido

```apex
RestContext.request.addHeader('Access_token', 'Bearer INVALIDO');
```

Espera-se: `AccessException`

---

### 📭 Parâmetro obrigatório ausente

```apex
RestContext.request.addParameter('id', null);
```

Espera-se: `badRequest(...)` + `AuraHandledException` ou status 400

---

### 🧨 JSON inválido

```apex
RestContext.request.requestBody = Blob.valueOf('{ campo: valor }'); // erro de parse
```

Espera-se: `BadRequestException`

---

### ☁️ Sucesso

```apex
RestContext.request.addParameter('id', registroValido.Id);
RestContext.request.addHeader('Access_token', Label.BEARER_TOKEN);
```

Espera-se: status 200 + response JSON

---

Claro! Aqui está a revisão da seção **4.5 – Assertivas obrigatórias**, com correções de clareza, padronização e formatação em conformidade com o tom do Guia Rigoroso:

---

## 🧪 4.5 – Assertivas obrigatórias

### ✅ Estrutura básica

Sempre validar status da resposta e existência do corpo da resposta:

```apex
System.assertEquals(200, RestContext.response.statusCode, 'Status HTTP inesperado: ' + RestContext.response.statusCode);
System.assertNotEquals(null, RestContext.response.responseBody, 'Body da resposta não pode ser nulo.');
```

### 🚨 Em caso de exceções esperadas

Capturar a exceção e validar explicitamente o comportamento:

```apex
Boolean erro = false;

try {
    MinhaClasseREST.metodo();
} catch (RestServiceHelper.AccessException e) {
    erro = true;
}

System.assertEquals(true, erro, 'Exceção esperada não foi lançada.');
```

---

### 🔎 Mensagens de `System.assert` devem conter o valor real retornado

Para facilitar o diagnóstico de falhas em testes, **todas as assertivas devem conter mensagens descritivas com os valores esperados e recebidos**.

#### ✅ Correto:
```apex
System.assertEquals('joão', contato.FirstName.toLowerCase(), 'Nome do contato inválido: ' + contato.FirstName);
System.assert(response.toLowerCase().contains('erro'), 'Resposta esperada deve conter "erro". Resposta completa: ' + response);
```

#### ❌ Incorreto:
```apex
System.assertEquals('joão', contato.FirstName.toLowerCase());
System.assert(response.toLowerCase().contains('erro'));
```

> 🧠 **Dica**: Mensagens claras reduzem drasticamente o tempo de debug quando um teste falha no CI ou em sandbox.

---



## 💡 4.6 – Método auxiliar para mock reutilizável

```apex
private static void mockRequest(String metodo, String uri, String token, String json) {
    RestContext.request = new RestRequest();
    RestContext.response = new RestResponse();
    RestContext.request.httpMethod = metodo;
    RestContext.request.requestURI = uri;
    if (token != null) RestContext.request.addHeader('Access_token', token);
    if (json != null) RestContext.request.requestBody = Blob.valueOf(json);
}
```

---

## 🚫 4.7 – Sintaxes proibidas

| ❌ Proibido                           | Motivo |
|-------------------------------------|--------|
| Omitir `RestContext.response`       | NullPointer na resposta |
| `System.debug` em produção          | Fora do padrão |
| Testar só sucesso (sem cenários inválidos) | Cobertura incompleta |

---

# 🧩 CAPÍTULO 5 – Testes Obrigatórios para Métodos `@TestVisible` Privados

---

## 🎯 Objetivo

Validar isoladamente métodos privados que contêm:

- Validação de parâmetros
- Lançamento de exceções
- Montagem de objetos de resposta
- Uso de logs, truncamentos, etc.

---

## ✅ Regra absoluta

> Todo método `private` deve ser `@TestVisible`  
> E **deve ser testado** diretamente nos testes da classe principal

---

## ⚠️ Cenários obrigatórios por método

| Tipo                          | Cenário positivo | Cenário negativo |
|-------------------------------|------------------|------------------|
| `validate*` ou `check*`       | Parâmetro válido | Parâmetro nulo ou inválido |
| `build*` ou `assemble*`       | Objeto populado  | Objeto nulo ou parcial |
| `log*` ou `truncate*`         | Entrada válida   | Entrada vazia ou longa demais |

---

## ✅ Exemplo padrão

```apex
@IsTest
static void validateRecordIdTest() {
    RestContext.request = new RestRequest();
    RestContext.response = new RestResponse();

    Boolean exceptionThrown = false;
    try {
        MinhaClasse.validateRecordId(null);
    } catch (AuraHandledException e) {
        exceptionThrown = true;
        System.assert(e.getMessage().contains('inválido'));
    }
    System.assertEquals(true, exceptionThrown);
}
```

---

## ⚠️ Observação importante sobre AuraHandledException:
Durante testes, o método getMessage() pode retornar "Script-thrown exception" ao invés da mensagem definida.
Por isso, recomenda-se validar apenas a ocorrência da exceção, e não sua mensagem, para garantir estabilidade dos testes.

---

## 🔒 Regras adicionais

- Não usar `@TestVisible` se o método for irrelevante (ex: getters/setters simples)
- Usar sempre parâmetros **primitivos ou SObjects mockados**
- Deve haver pelo menos **1 teste de sucesso** e **1 de erro** para cada método testável

---

## 🧠 Recomendações finais

- Usar `@TestVisible` como forma de garantir **contratos testáveis** para lógica auxiliar
- Documentar com `// @Tested` ao lado do método testado
- Garantir cobertura mínima de 95% nos testes de REST e services

---

📌 Essa diretriz deve ser adicionada no **[Guia Rigoroso de Testes Apex](https://bit.ly/GuiaTestsApex)** — pois trata diretamente de **como construir e usar dados de teste de forma padronizada e reutilizável**, especialmente no contexto do `TestDataSetup`.

---

## ✅ Local ideal: Capítulo 6 — Estrutura Modular de Dados de Teste

Você já tem lá a tabela com os `*TestDataSetup.cls`. Sugiro adicionar **uma nova seção 6.1** logo abaixo da tabela:

---

### 📘 6.1 – Obrigatoriedade de assinaturas simples para métodos `createXxx()`

Para garantir padronização e produtividade em testes, **todo método público de `*TestDataSetup` deve ter uma sobrecarga sem parâmetros**, com assinatura:

```apex
public static Tipo__c createXxx()
```

Essa versão deve:

- ✅ Criar registros válidos, completos e persistidos (`insert`)
- ✅ Usar valores default ou fallback seguros
- ✅ Delegar internamente para a versão com parâmetros (`createXxx(...params)`)

---

### ✅ Exemplo aplicado

```apex
public static UC__c createUC() {
    return createUC(null, null, null);
}
```

### ✅ Vantagens

- Permite escrever testes mais legíveis:  
  `UC__c uc = UcTestDataSetup.createUC();`
- Elimina necessidade de conhecer a ordem dos parâmetros
- Evita repetição e erro humano

---

### 🔒 Regras obrigatórias

| Regra                                            | Status |
|--------------------------------------------------|--------|
| A assinatura sem parâmetros **deve existir**     | ✅     |
| Deve chamar a versão principal com `null`        | ✅     |
| O método principal deve garantir fallback internos| ✅     |
| Apenas `TestDataSetup` pode usar lógica composta | ✅     |

---


### 📎 Compatibilidade com os guias oficiais
- [ ] [Guia de Revisão Apex](https://bit.ly/GuiaApexRevisao)
- [ ] [Guia de Testes Apex](https://bit.ly/GuiaTestsApex)
- [ ] [Guia de Logging](https://bit.ly/GuiaLoggerApex)
- [ ] [Guia de Refatoração Apex](https://bit.ly/ComparacaoApex)
- [ ] [Classe orquestradora `TestDataSetup.cls`](https://bit.ly/TestDataSetup)
- [ ] [Checklist de Confirmação Final](https://bit.ly/ConfirmacaoApex)

---
