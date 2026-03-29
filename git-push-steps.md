# Passos para fazer um git push

## O que é Git?

Git é um **sistema de controle de versão distribuído** que permite rastrear mudanças em arquivos e colaborar com outras pessoas no desenvolvimento de projetos. Com Git, você pode:

- Registrar o histórico de todas as alterações no seu código
- Reverter para versões anteriores se necessário
- Trabalhar em paralelo com outras pessoas (branches)
- Manter um backup centralizado do seu projeto (no GitHub, GitLab, etc.)

## Passos para fazer um git push

1. Verificar o status das mudanças:
   ```bash
   git status
   ```

2. Adicionar os arquivos modificados:
   ```bash
   git add <arquivo>
   # ou para todos os arquivos
   git add .
   ```

3. Criar um commit (seguindo o padrão **Conventional Commits**):
   ```bash
   git commit -m "sua mensagem aqui"
   ```

4. Enviar para o GitHub:
   ```bash
   git push origin main
   ```

   Formato: `<tipo>: <descrição curta em imperativo>`

   | Tipo | Quando usar |
   |------|-------------|
   | `feat` | nova funcionalidade |
   | `fix` | correção de bug |
   | `docs` | mudanças em documentação |
   | `refactor` | refatoração sem mudar comportamento |
   | `chore` | tarefas de manutenção (gitignore, configs) |

   Exemplos:
   ```
   feat: add ALS implementation notebook
   docs: add CLAUDE.md with project structure
   chore: add .claude/ to .gitignore
   ```

   Regras:
   - Menos de 72 caracteres
   - Usar o imperativo: "add", "fix", "update" (não "added", "fixed")
   - Escrever em inglês

## Quando criar um Pull Request (PR)?

Pull Requests são usados quando você trabalha **em equipe** ou em **projetos open source**:

- Você quer adicionar código ao repositório de outra pessoa
- Você trabalha em um time e precisa de revisão antes de fazer merge
- Você quer propor uma mudança sem ter permissão de fazer push direto

Em repositórios pessoais (trabalhando sozinho), não é necessário — fazer push direto para `main` é suficiente.

## Como criar um PR

1. Criar e mudar para uma nova branch:
   ```bash
   git checkout -b nome-da-branch
   ```

2. Fazer suas mudanças, adicionar e commitar normalmente:
   ```bash
   git add .
   git commit -m "feat: minha mudança"
   ```

3. Enviar a branch para o GitHub:
   ```bash
   git push origin nome-da-branch
   ```

4. Abrir o PR via GitHub CLI:
   ```bash
   gh pr create --title "Título do PR" --body "Descrição das mudanças"
   ```
   Ou acessar o repositório no GitHub — ele mostrará um botão **"Compare & pull request"** automaticamente.

