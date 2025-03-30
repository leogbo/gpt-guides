# ✅ Guia de Confirmação de Equivalência Funcional – v2025 (Mentalidade Mamba)

📎 **Shortlink oficial:** [bit.ly/ConfirmacaoApex](https://bit.ly/ConfirmacaoApex)

> “Se você mexeu, você prova que não quebrou.” – Mentalidade Mamba 🧠🔥

Este guia define o processo obrigatório para **confirmar que uma refatoração preserva 100% da funcionalidade original**. Nenhuma alteração de método, helper ou fluxo crítico é aceita sem confirmação formal.

---

## 📚 Guias complementares obrigatórios

- 📘 [Guia Master de Arquitetura](https://bit.ly/GuiaApexMamba)
- 🔍 [Guia de Revisão](https://bit.ly/GuiaApexRevisao)
- 🔁 [Guia de Comparações de Código](https://bit.ly/ComparacaoApex)
- 🧪 [Guia de Testes](https://bit.ly/GuiaTestsApex)

---

## ✅ O que é equivalência funcional?

> Significa que a versão refatorada:
> - Retorna os mesmos outputs
> - Gera os mesmos logs (se aplicável)
> - Não altera comportamento para nenhuma entrada conhecida
> - Passa nos mesmos testes sem alteração nos asserts
> - Mantém compatibilidade com contratos anteriores (ex: nome e assinatura de método)

---

## ✅ Como provar equivalência?

1. Executar todos os testes atuais da classe afetada (sem alterar asserts)
2. Adicionar testes novos para caminhos recém-explicitados (ex: tratamento de `null` ou prefixo inválido)
3. Confirmar que nenhuma entrada válida passou a gerar erro
4. Validar que logs continuam com mesma estrutura (se aplicável)
5. Validar persistência em `FlowExecutionLog__c` se for REST ou serviço crítico
6. Confirmar que métodos públicos/refatorados não quebram quem já os consome

---

## 🧪 Exemplo de confirmação:

### 🔬 Exemplo real de teste que valida equivalência funcional
```apex
@IsTest
static void deve_manter_comportamento_apos_refatoracao() {
    ClientPortalService.exceptionThrown = false;
    Map<String, Object> req = mockRequestDataUpdateLoginPassword('UC__c', 'login', 'senha');

    try {
        ClientPortalService.handleUpdateLoginPassword(req);
    } catch (RestServiceHelper.BadRequestException e) {
        System.assert(ClientPortalService.exceptionThrown, 'Flag de exceção não foi ativada.');
    }
}
```

### 📄 Snippet para Pull Request
```markdown
### 🧠 Confirmação de Equivalência Funcional

- Nenhum assert foi alterado
- Comportamento validado com `exceptionThrown` (exceção rastreável)
- JSON de resposta idêntico ao anterior
- `FlowExecutionLog__c` mantido com mesma categoria e estrutura
- Método `handleUpdateLoginPassword()` refatorado mantendo assinatura e retorno
```

```markdown
### Equivalência validada:
- Todos os testes passaram sem alteração
- Adicionado teste para `id == null`
- LoggerMock ativado e nenhum log inesperado gerado
- Método refatorado continua retornando o mesmo wrapper
- Nome e assinatura do método original preservados
```

---

## ✅ Quando é obrigatória?

### 📦 Exemplo real: criação de nova versão REST sem quebrar JSON anterior

#### ❌ Errado: mudança no mesmo endpoint
```apex
@RestResource(urlMapping='/api/cliente')
global with sharing class ClienteService {
    @HttpGet
    global static void getCliente() {
        // versão antiga retornava apenas nome
        RestContext.response.responseBody = Blob.valueOf('{"nome": "João"}');
    }
}
```

#### ✅ Correto: nova versão paralela
```apex
@RestResource(urlMapping='/api/v2/cliente')
global with sharing class ClienteServiceV2 {
    @HttpGet
    global static void getCliente() {
        // nova versão adiciona CPF sem quebrar a anterior
        RestContext.response.responseBody = Blob.valueOf('{"nome": "João", "cpf": "12345678900"}');
    }
}
```

> 📌 A versão v1 continua ativa e compatível até ser oficialmente descontinuada por processo versionado.

> ⚠️ **Atenção especial**: Para serviços REST ou classes que fazem parsing de JSON (entrada ou saída), a equivalência funcional **é inegociável**. O retorno deve manter o mesmo shape de JSON. Se for necessário mudar, **crie uma nova classe ou versão (v2)** mantendo a anterior ativa até ser oficialmente desativada.

| Situação                                        | Equivalência exigida? |
| ----------------------------------------------- | --------------------- |
| Refatoração de método público ou `@TestVisible` | ✅                     |
| Substituição de `SELECT` direto por helper      | ✅                     |
| Troca de serialização, log ou fallback          | ✅                     |
| Alteração de lógica condicional crítica         | ✅                     |
| Inclusão de log                                 | ⚠️ Se afeta estrutura |
| Mudança puramente estética                      | ❌                     |
| Novo método auxiliar com sobrecarga             | ⚠️ Avaliar impacto    |

---

## 📌 Dica prática:

Antes de refatorar, rode todos os testes.  
Depois de refatorar, **não altere nenhum teste** e rode de novo. Se passar: você provou equivalência.

Para métodos REST ou de serviço: compare também JSONs de resposta e logs no `FlowExecutionLog__c`.

---

## 🧠 Checklist de Confirmação Mamba

| Item                                                        | Verificado? |
|-------------------------------------------------------------|-------------|
| Todos os testes passaram após refatoração                   | [ ]         |
| Nenhum assert foi modificado                                | [ ]         |
| Adicionado teste novo se havia caminho não coberto          | [ ]         |
| Logs mantêm mesma estrutura e categoria                     | [ ]         |
| Payloads JSON e FlowExecutionLog inalterados (se REST)      | [ ]         |
| Nome e assinatura dos métodos foram mantidos                | [ ]         |
| Pull Request contém seção de confirmação explícita          | [ ]         |
| Compatibilidade com integrações e chamadas existentes        | [ ]         |
| Nenhum breaking change em retorno ou exceções lançadas      | [ ]         |

---

> **“Toda melhoria precisa de prova. Toda prova precisa de contexto.” — Mentalidade Mamba**

🧠🧱🧪 #EquivalenciaComprova #NadaMudaSemProva #ConfirmaAntesDeMerge

