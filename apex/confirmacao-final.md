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
> - Gera os mesmos logs
> - Não altera comportamento para nenhuma entrada conhecida
> - Passa nos mesmos testes sem alteração nos asserts

---

## ✅ Como provar equivalência?

1. Executar todos os testes atuais da classe afetada (sem alterar asserts)
2. Adicionar testes novos para caminhos recém-explicitados
3. Confirmar que nenhuma entrada válida passou a gerar erro
4. Validar que logs continuam aparecendo com mesma estrutura (se aplicável)
5. Validar `FlowExecutionLog__c` se for REST ou serviço crítico

---

## 🧪 Exemplo de confirmação:

```markdown
### Equivalência validada:
- Todos os testes passaram sem alteração
- Adicionado teste para `id == null`
- LoggerMock ativado e nenhum log inesperado gerado
- Método refatorado continua retornando o mesmo wrapper
```

---

## ✅ Quando é obrigatória?

| Situação                                     | Equivalência exigida? |
|----------------------------------------------|------------------------|
| Refatoração de método público ou `@TestVisible`| ✅                     |
| Substituição de `SELECT` direto por helper   | ✅                     |
| Troca de serialização ou fallback            | ✅                     |
| Alteração de lógica condicional crítica      | ✅                     |
| Inclusão de log                              | ⚠️ Se afeta estrutura  |
| Mudança puramente estética                   | ❌                     |

---

## 📌 Dica prática:

Antes de refatorar, rode todos os testes.  
Depois de refatorar, **não altere nenhum teste** e rode de novo. Se passar: você provou equivalência.

---

## 🧠 Checklist de Confirmação Mamba

| Item                                                        | Verificado? |
|-------------------------------------------------------------|-------------|
| Todos os testes passaram após refatoração                   | [ ]         |
| Nenhum assert foi modificado                                | [ ]         |
| Adicionado teste novo se havia caminho não coberto          | [ ]         |
| Logs mantêm mesma estrutura e categoria                     | [ ]         |
| Payloads JSON e FlowExecutionLog inalterados (se REST)      | [ ]         |
| Pull Request contém seção de confirmação explícita          | [ ]         |

---

🧠🧱🧪 #EquivalenciaComprova #NadaMudaSemProva #ConfirmaAntesDeMerge

