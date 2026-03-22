#!/bin/bash

# ============================================
# Nmap Reconnaissance Commands Reference
# Projeto Kali Linux + Medusa - DIO
# ============================================

TARGET_IP="192.168.1.100"
TARGET_RANGE="192.168.1.0/24"

echo "=== REFERÊNCIA DE COMANDOS NMAP ==="
echo ""

# ============================================
# 1. PING SCAN (Descoberta de Hosts)
# ============================================

echo "[1] PING SCAN - Descobrir hosts vivos na rede"
echo "---"
echo "Comando básico:"
echo "nmap -sn $TARGET_RANGE"
echo ""
echo "Com saída detalhada:"
echo "nmap -sn $TARGET_RANGE -v"
echo ""
echo "Flag explicada:"
echo "  -sn: Ping scan (sem port scan)"
echo "  -v:  Verbose"
echo ""

# ============================================
# 2. PORT SCAN (Top Portas)
# ============================================

echo "[2] PORT SCAN - Top 20 portas"
echo "---"
echo "Comando:"
echo "nmap --top-ports 20 $TARGET_IP"
echo ""
echo "Com informações de versão:"
echo "nmap -sV --top-ports 20 $TARGET_IP"
echo ""
echo "Parâmetros:"
echo "  --top-ports 20: Escaneia apenas 20 portas mais comuns"
echo "  -sV:  Detecção de versão de serviço"
echo ""

# ============================================
# 3. FULL PORT SCAN (Todas as Portas)
# ============================================

echo "[3] FULL PORT SCAN - Todas as 65535 portas"
echo "---"
echo "Aviso: LENTO! (~20-30 minutos)"
echo ""
echo "Comando:"
echo "nmap -p- $TARGET_IP"
echo ""
echo "Com versão (muito mais lento):"
echo "nmap -p- -sV $TARGET_IP"
echo ""
echo "Modo paranoia (evitar detecção):"
echo "nmap -p- -T1 $TARGET_IP  (muito lento)"
echo ""

# ============================================
# 4. OS DETECTION
# ============================================

echo "[4] OS DETECTION - Detectar sistema operacional"
echo "---"
echo "Comando:"
echo "nmap -O $TARGET_IP"
echo ""
echo "Combinado com versão:"
echo "nmap -A $TARGET_IP  (-O -sV -sC -vvv)"
echo ""

# ============================================
# 5. SCRIPT SCANNING
# ============================================

echo "[5] SCRIPT SCANNING - Scripts NSE"
echo "---"
echo "Enumerar usuários SMB:"
echo "nmap -p 139,445 --script smb-enum-users.nse $TARGET_IP"
echo ""
echo "Enumerar compartilhamentos SMB:"
echo "nmap -p 139,445 --script smb-enum-shares.nse $TARGET_IP"
echo ""
echo "Verificar vulnerabilidades SMB:"
echo "nmap -p 139,445 --script smb-vuln-* $TARGET_IP"
echo ""
echo "Múltiplos scripts:"
echo "nmap -p 139,445 --script smb-enum* $TARGET_IP"
echo ""

# ============================================
# 6. AGGRESSIVE SCAN
# ============================================

echo "[6] AGGRESSIVE SCAN - Scan Completo"
echo "---"
echo "Comando (tudo junto):"
echo "nmap -A -p- $TARGET_IP"
echo ""
echo "Flags:"
echo "  -A: Aggressive (OS, Version, Scripts, Traceroute)"
echo "  -p-: Todas as portas"
echo ""
echo "Muito lento! Melhor abordagem:"
echo "nmap -sV --top-ports 20 $TARGET_IP  (rápido)"
echo "nmap -p 139,445 --script smb-enum*.nse $TARGET_IP  (SMB específico)"
echo "nmap -p 21 --script ftp-*.nse $TARGET_IP  (FTP específico)"
echo ""

# ============================================
# 7. OUTPUT FORMATS
# ============================================

echo "[7] OUTPUT FORMATS - Salvar resultados"
echo "---"
echo "Formato de texto:"
echo "nmap $TARGET_IP -o nmap-result.txt"
echo ""
echo "Formato XML:"
echo "nmap $TARGET_IP -oX nmap-result.xml"
echo ""
echo "Todos os formatos:"
echo "nmap $TARGET_IP -oA nmap-result  (txt, xml, gnmap)"
echo ""

# ============================================
# 8. TIMING TEMPLATES
# ============================================

echo "[8] TIMING TEMPLATES - Controlar velocidade"
echo "---"
echo "0 (paranoid): Muito lento, evita detecção"
echo "  nmap -T0 $TARGET_IP"
echo ""
echo "1 (sneaky): Lento, evita IDS"
echo "  nmap -T1 $TARGET_IP"
echo ""
echo "2 (polite): Padrão, respeita banda"
echo "  nmap -T2 $TARGET_IP"
echo ""
echo "3 (normal): PADRÃO, balanceado"
echo "  nmap -sV --top-ports 20 $TARGET_IP"
echo ""
echo "4 (aggressive): Rápido, pode ser detectado"
echo "  nmap -T4 -p- $TARGET_IP"
echo ""
echo "5 (insane): Muito rápido, frequentemente detectado"
echo "  nmap -T5 -p- $TARGET_IP"
echo ""

# ============================================
# 9. EXEMPLOS PRÁCTICOS
# ============================================

echo "[9] EXEMPLOS PRÁTICOS"
echo "---"
echo "Scenario 1: Reconhecimento Rápido"
echo "nmap -sV --top-ports 20 $TARGET_IP"
echo ""
echo "Scenario 2: Teste FTP"
echo "nmap -p 21 --script ftp-* $TARGET_IP"
echo ""
echo "Scenario 3: Teste SMB"
echo "nmap -p 139,445 --script smb-enum* $TARGET_IP"
echo ""
echo "Scenario 4: Teste HTTP"
echo "nmap -p 80,443 --script http-* $TARGET_IP"
echo ""
echo "Scenario 5: Full Reconnaissance (LENTO)"
echo "nmap -A -p- -vvv -T4 $TARGET_IP -oA nmap-full"
echo ""

# ============================================
# 10. FILTER E ANALISE
# ============================================

echo "[10] FILTER & ANALYSIS"
echo "---"
echo "Extrair apenas portas abertas de saída XML:"
echo "grep \"state state=\" nmap-result.xml"
echo ""
echo "Parsing com grep:"
echo "nmap $TARGET_IP | grep open"
echo ""
echo "Contar portas abertas:"
echo "nmap $TARGET_IP | grep open | wc -l"
echo ""

echo ""
echo "=== FIM DA REFERÊNCIA ==="
