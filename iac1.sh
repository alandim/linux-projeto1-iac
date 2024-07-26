#!/bin/bash

# Definindo variáveis
GROUPS=("departamento1" "departamento2" "departamento3")
USERS=("usuario1:departamento1" "usuario2:departamento2" "usuario3:departamento3")
DIRS=("/publico" "/departamento1" "/departamento2" "/departamento3")

# Remover usuários, grupos e diretórios criados anteriormente
for USER in "${USERS[@]}"; do
    USERNAME="${USER%%:*}"
    if id -u "$USERNAME" >/dev/null 2>&1; then
        userdel -r "$USERNAME"
    fi
done

for GROUP in "${GROUPS[@]}"; do
    if getent group "$GROUP" >/dev/null 2>&1; then
        groupdel "$GROUP"
    fi
done

for DIR in "${DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        rm -rf "$DIR"
    fi
done

# Criar grupos
for GROUP in "${GROUPS[@]}"; do
    groupadd "$GROUP"
done

# Criar usuários e adicionar aos grupos
for USER in "${USERS[@]}"; do
    USERNAME="${USER%%:*}"
    GROUPNAME="${USER##*:}"
    useradd -m -G "$GROUPNAME" "$USERNAME"
done

# Criar diretórios
mkdir -p /publico
for DIR in "${DIRS[@]:1}"; do
    mkdir -p "$DIR"
done

# Definir o dono dos diretórios como root
chown root:root /publico
for DIR in "${DIRS[@]:1}"; do
    chown root:root "$DIR"
done

# Definir permissões
chmod 777 /publico
for DIR in "${DIRS[@]:1}"; do
    chmod 770 "$DIR"
done

# Permitir que todos os usuários tenham acesso ao diretório público
for USER in "${USERS[@]}"; do
    USERNAME="${USER%%:*}"
    setfacl -m u:$USERNAME:rwx /publico
done

echo "Provisionamento concluído."
