#!/usr/bin/env bash
echo "===== Configurando Git ====="

read -rp "Digite seu nome para o Git: " GIT_NAME
while [[ -z "$GIT_NAME" ]]; do
    read -rp "Nome não pode ser vazio. Digite novamente: " GIT_NAME
done

read -rp "Digite seu email para o Git/GitHub: " GIT_EMAIL
while [[ -z "$GIT_EMAIL" ]]; do
    read -rp "Email não pode ser vazio. Digite novamente: " GIT_EMAIL
done

git config --global user.name  "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

git config --global init.defaultBranch main
git config --global core.editor nvim
git config --global fetch.prune true

git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.graph 'log --oneline --graph --decorate --all'

echo "===== Configurando SSH ====="
if [[ ! -f ~/.ssh/id_ed25519 ]]; then
    echo "Gerando chave SSH..."
    ssh-keygen -t ed25519 -C "$GIT_EMAIL"

    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519

    echo
    echo "COPIE A CHAVE ABAIXO E ADICIONE NO GITHUB:"
    echo "----------------------------------------"
    cat ~/.ssh/id_ed25519.pub
    echo "----------------------------------------"
    echo

    read -rp "Digite 'y' após adicionar a chave no GitHub: " OK
    [[ "${OK,,}" == "y" ]] || exit 1
fi