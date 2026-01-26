#!/usr/bin/env bash
set -euo pipefail

AUR_LIST="aur.txt"
AUR_DIR="$HOME/aur"

echo "===== Escolha o ambiente gráfico ====="
echo "1) i3 (X11)"
echo "2) Hyprland (Wayland)"
echo

read -rp "Digite 1 ou 2: " WM_CHOICE

case "$WM_CHOICE" in
    1)
        PACMAN_LIST="pacotes_i3.txt"
        WM_NAME="i3"
        ;;
    2)
        PACMAN_LIST="pacotes_hyprland.txt"
        WM_NAME="hyprland"
        ;;
    *)
        echo "Opção inválida."
        exit 1
        ;;
esac

echo
echo "Ambiente selecionado: $WM_NAME"
echo

if [[ ! -f "$PACMAN_LIST" ]]; then
    echo "Arquivo $PACMAN_LIST não encontrado."
    exit 1
fi

echo "===== Atualizando sistema ====="
sudo pacman -Syu --noconfirm

echo "===== Instalando pacotes do pacman ($WM_NAME) ====="
while read -r pacote; do
    [[ -z "$pacote" || "$pacote" =~ ^# ]] && continue
    sudo pacman -S --needed --noconfirm "$pacote"
done < "$PACMAN_LIST"

echo "===== Instalando yay ====="
if ! command -v yay >/dev/null; then
    sudo pacman -S --needed --noconfirm base-devel git
    mkdir -p "$AUR_DIR"
    git clone https://aur.archlinux.org/yay.git "$AUR_DIR/yay"
    cd "$AUR_DIR/yay"
    makepkg -si --noconfirm
    cd
fi

echo "===== Instalando pacotes AUR ====="
while read -r pacote; do
    [[ -z "$pacote" || "$pacote" =~ ^# ]] && continue
    yay -S --needed --noconfirm "$pacote"
done < "$AUR_LIST"

echo "===== Clonando configurações ====="
read -rp "Git/GitHub está configurado? [Y/n]: " RESPOSTA

case "$RESPOSTA" in
    [Y]|"")
        echo "Clonando via SSH..."
        git clone git@github.com:enthonyaraujo/dotfiles.git
        ;;
    [y]|"")
        echo "Clonando via SSH..."
        git clone git@github.com:enthonyaraujo/dotfiles.git
        ;;
    [N])
        echo "Clonando via HTTPS..."
        git clone https://github.com/enthonyaraujo/dotfiles.git
        ;;
    [n])
        echo "Clonando via HTTPS..."
        git clone https://github.com/enthonyaraujo/dotfiles.git
        ;;
    *)
        echo "Resposta inválida. Use Y/y ou N/n."
        exit 1
        ;;
esac

echo "===== Mudando shell para ZSH ====="
if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
    chsh -s /usr/bin/zsh
fi

echo
echo "===== Setup finalizado ====="
echo "Ambiente instalado: $WM_NAME"
echo "Faça logout/login para aplicar tudo."
