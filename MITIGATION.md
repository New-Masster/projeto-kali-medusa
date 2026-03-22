# 🛡️ Estratégias de Mitigação Contra Ataques de Força Bruta

Este documento detalha **como defender** contra os ataques simulados neste projeto. A mitigação é tão importante quanto a compreensão dos ataques.

---

## 📌 Índice

1. [Defesa Contra Brute Force FTP](#1-defesa-contra-brute-force-ftp)
2. [Defesa de Aplicações Web](#2-defesa-de-aplicações-web)
3. [Defesa Contra SMB Enumeration & Password Spraying](#3-defesa-contra-smb-enumeration--password-spraying)
4. [Soluções Genéricas (Todas as Camadas)](#4-soluções-genéricas-todas-as-camadas)
5. [Checklist de Implementação](#5-checklist-de-implementação)

---

## 1. Defesa Contra Brute Force FTP

### ❌ Problema Identificado

```
Serviço: FTP (vsftpd 2.3.4)
Vulnerabilidade: Permite múltiplas tentativas de login sem limite
Risco: Força bruta bem-sucedida em credenciais fracas
Impacto: Acesso não autorizado a arquivos no servidor
```

---

### ✅ Solução 1: Desabilitar FTP (Recomendado)

**Por que?** FTP é um protocolo legado inseguro (texto plano).

#### Implementação:

```bash
# Parar e desabilitar serviço FTP
sudo systemctl stop vsftpd
sudo systemctl disable vsftpd

# Remover pacote (opcional)
sudo apt-get remove vsftpd

# Verificar se foi removido
sudo systemctl is-active vsftpd
# Output: inactive (esperado)
```

#### Alternativas Seguras:

| Alternativa | Vantagem | Desvantagem |
|-------------|-----------|-------------|
| **SFTP** | Criptografia SSH nativa | Requer SSH |
| **SCP** | Simples e seguro | Apenas transferência |
| **Rsync sobre SSH** | Eficiente, sincronização | Mais complexo |
| **Cloud Storage** | Moderno, seguro | Requer infraestrutura |

---

### ✅ Solução 2: FTP com Rate Limiting

**Se FTP é necessário**, implementar proteção:

#### A. Rate Limiting via iptables

```bash
# Limitar a 5 conexões por IP, por minuto
sudo iptables -I INPUT -p tcp --dport 21 -i eth0 -m limit --limit 5/minute --limit-burst 10 -j ACCEPT

# Salvar regras
sudo sh -c 'iptables-save > /etc/iptables/rules.v4'

# Verificar
sudo iptables -L | grep 21
```

#### B. Rate Limiting via vsftpd.conf

```bash
# Editar configuração
sudo nano /etc/vsftpd.conf

# Adicionar ou modificar:
# Máximo de 10 tentativas de login antes de desconectar
max_login_fails=10

# Esperar 2 segundos entre tentativas (muito básico)
delay_failed_login=2

# Máximo 100 conexões simultâneas
max_clients=100

# Máximo 4 por IP
max_per_ip=4

# Reiniciar serviço
sudo systemctl restart vsftpd
```

**Limitação:** FTP não suporta delays sofisticados como HTTP.

---

### ✅ Solução 3: Exigir Senhas Fortes

```bash
# Instalar ferramenta de política de senhas
sudo apt-get install libpam-pwquality

# Editar política
sudo nano /etc/security/pwquality.conf

# Configurações recomendadas:
# Comprimento mínimo
minlen=14

# Pelo menos 1 maiúscula
ucredit=-1

# Pelo menos 1 minúscula
lcredit=-1

# Pelo menos 1 dígito
dcredit=-1

# Pelo menos 1 caractere especial
ocredit=-1

# Não reutilizar senhas anteriores
remember=5

# Exigir mudança de senha a cada 90 dias
#/etc/login.defs
# PASS_MAX_DAYS   90
# PASS_MIN_DAYS   1
# PASS_WARN_AGE   7
```

**Teste:**
```bash
# Tentar mudar senha
passwd

# Senha fraca será rejeitada
# New password: test123
# BAD PASSWORD: The password fails the dictionary check
```

---

### ✅ Solução 4: Desabilitar Conta Após Falhas

```bash
# Instalar ferramenta
sudo apt-get install libpam-cracklib

# Editar /etc/pam.d/common-auth
# Adicionar (após autenticação):
auth required pam_tally2.so onerr=fail audit silent deny=5 unlock_time=600

# Quando ativado:
# - 5 falhas = conta bloqueada
# - Desbloqueio automático em 600 segundos (10 minutos)

# Desbloquear manualmente se necessário
sudo pam_tally2 --user msfadmin --reset
```

---

### ✅ Solução 5: Monitoramento e Alertas

```bash
# Instalar Fail2Ban
sudo apt-get install fail2ban

# Configurar para FTP
sudo nano /etc/fail2ban/jail.d/ftp.conf

# Adicionar:
[vsftpd]
enabled = true
port = ftp
filter = vsftpd
logpath = /var/log/vsftpd.log
maxretry = 5          # 5 tentativas falhas
findtime = 600        # em 10 minutos
bantime = 3600        # banir por 1 hora

# Iniciar serviço
sudo systemctl restart fail2ban

# Monitorar bloqueios
sudo fail2ban-client status vsftpd
```

---

## 2. Defesa de Aplicações Web

### ❌ Problema Identificado (DVWA Nível Low)

```
Aplicação: DVWA
Vulnerabilidade: Nenhuma proteção contra brute force
Risco: Força bruta contra formulários de login
Impacto: Acesso não autorizado a conta de usuário
```

---

### ✅ Solução 1: Rate Limiting HTTP

#### Implementação em Apache/PHP:

**A. Rate Limiting via Apache:**

```apache
# /etc/apache2/mods-available/mod_ratelimit.conf
<Location /login.php>
    SetOutputFilter RATE_LIMIT
    SetEnv RATE_LIMIT 10
</Location>

# Máximo 10 requisições por segundo para /login.php
```

**B. Rate Limiting via PHP:**

```php
<?php
// rates-limit.php
session_start();

$max_attempts = 5;
$timeout = 900; // 15 minutos

$ip = $_SERVER['REMOTE_ADDR'];
$cache_key = "rate_limit_" . md5($ip);

// Redis ou memcached
if (isset($_SESSION[$cache_key])) {
    $attempts = $_SESSION[$cache_key]['count'];
    $last_attempt = $_SESSION[$cache_key]['time'];
    
    if (time() - $last_attempt < $timeout) {
        if ($attempts >= $max_attempts) {
            die("Muitas tentativas de login. Tente novamente em " . 
                ($timeout - (time() - $last_attempt)) . " segundos");
        }
        $_SESSION[$cache_key]['count']++;
    } else {
        $_SESSION[$cache_key] = ['count' => 1, 'time' => time()];
    }
} else {
    $_SESSION[$cache_key] = ['count' => 1, 'time' => time()];
}
?>
```

#### Implementação em Node.js/Express:

```javascript
const rateLimit = require('express-rate-limit');

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 5,                     // 5 tentativas máximo
  message: 'Muitas tentativas de login, tente novamente depois',
  standardHeaders: true,
  legacyHeaders: false,
});

app.post('/login', loginLimiter, (req, res) => {
  // Lógica de autenticação
});
```

---

### ✅ Solução 2: CAPTCHA

#### Google reCAPTCHA v3:

```html
<!-- HTML do Formulário -->
<form id="login-form" method="POST">
    <input type="text" name="username" required>
    <input type="password" name="password" required>
    <button type="submit">Login</button>
</form>

<script src="https://www.google.com/recaptcha/api.js"></script>
<script>
    document.getElementById('login-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const token = await grecaptcha.execute('SITE_KEY', {action: 'login'});
        
        const formData = new FormData(e.target);
        formData.append('recaptcha_token', token);
        
        // Enviar para servidor
        fetch('/login', {
            method: 'POST',
            body: formData
        });
    });
</script>
```

#### Verificação no Backend (Node.js):

```javascript
app.post('/login', async (req, res) => {
    const token = req.body.recaptcha_token;
    
    // Verificar com Google
    const response = await fetch('https://www.google.com/recaptcha/api/siteverify', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: `secret=${RECAPTCHA_SECRET}&response=${token}`
    });
    
    const data = await response.json();
    
    if (data.success && data.score > 0.5) {
        // Continuar com autenticação
        authenticateUser(req.body.username, req.body.password);
    } else {
        res.status(403).send('reCAPTCHA failed');
    }
});
```

---

### ✅ Solução 3: Multi-Factor Authentication (MFA)

#### TOTP com Google Authenticator:

**Setup Inicial:**

```python
# setup_mfa.py (Python Flask)
import pyotp
import qrcode
from io import BytesIO

def enable_mfa(user_id):
    # Gerar secret
    secret = pyotp.random_base32()
    
    # Armazenar no banco (criptografado!)
    user.mfa_secret = encrypt(secret)
    user.mfa_enabled = True
    db.commit()
    
    # Gerar QR code
    totp = pyotp.TOTP(secret)
    uri = totp.provisioning_uri(user.email, 'MyApp')
    
    qr = qrcode.QRCode()
    qr.add_data(uri)
    qr.make()
    
    img = qr.make_image()
    return img
```

**Login com MFA:**

```python
@app.route('/login', methods=['POST'])
def login():
    username = request.form['username']
    password = request.form['password']
    
    user = User.query.filter_by(username=username).first()
    
    # Verificar senha
    if not user or not verify_password(user.password_hash, password):
        return render_template('login.html', error='Credenciais inválidas')
    
    # Se MFA habilitado
    if user.mfa_enabled:
        # Mostrar tela de verificação MFA
        return render_template('mfa_verify.html', user_id=user.id)
    
    # Caso contrário, fazer login
    session['user_id'] = user.id
    return redirect('/dashboard')

@app.route('/verify-mfa', methods=['POST'])
def verify_mfa():
    user_id = session.get('user_id_temp')
    totp_input = request.form['totp']
    
    user = User.query.get(user_id)
    secret = decrypt(user.mfa_secret)
    
    totp = pyotp.TOTP(secret)
    
    if totp.verify(totp_input):
        session['user_id'] = user.id
        del session['user_id_temp']
        return redirect('/dashboard')
    else:
        return render_template('mfa_verify.html', error='Código temporário inválido')
```

---

### ✅ Solução 4: Account Lockout Policy

```php
<?php
// login.php com account lockout

$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

$user = $db->query("SELECT * FROM users WHERE username = ?", [$username])->fetch();

if (!$user) {
    die('Usuário não encontrado');
}

// Verificar se conta está bloqueada
if ($user['locked'] && time() < $user['locked_until']) {
    $remaining = $user['locked_until'] - time();
    die("Conta bloqueada. Tente novamente em $remaining segundos");
}

// Verificar senha
if (!password_verify($password, $user['password_hash'])) {
    // Incrementar tentativas falhas
    $failed_attempts = $user['failed_attempts'] + 1;
    
    if ($failed_attempts >= 5) {
        // Bloquear por 30 minutos
        $locked_until = time() + (30 * 60);
        $db->query(
            "UPDATE users SET failed_attempts = ?, locked = 1, locked_until = ? WHERE id = ?",
            [$failed_attempts, $locked_until, $user['id']]
        );
        die("Muitas tentativas falhas. Conta bloqueada por 30 minutos");
    }
    
    // Incrementar contador
    $db->query("UPDATE users SET failed_attempts = ? WHERE id = ?", [$failed_attempts, $user['id']]);
    die("Senha inválida. Tentativas restantes: " . (5 - $failed_attempts));
}

// Sucesso: resetar contador e login
$db->query("UPDATE users SET failed_attempts = 0, locked = 0 WHERE id = ?", [$user['id']]);
session_start();
$_SESSION['user_id'] = $user['id'];
header('Location: /dashboard');
?>
```

---

### ✅ Solução 5: WAF (Web Application Firewall)

#### Usando ModSecurity (Apache):

```bash
# Instalar ModSecurity
sudo apt-get install libapache2-mod-security2

# Habilitar módulo
sudo a2enmod security2

# Copiar regras OWASP
sudo wget https://github.com/coreruleset/coreruleset/archive/v3.3.0.tar.gz
sudo tar -xzf v3.3.0.tar.gz
sudo cp coreruleset-3.3.0/crs-setup.conf.example /etc/modsecurity.d/

# Configurar regra específica para login brute force
echo '
SecRule REQUEST_URI "@streq /login.php" \
    "id:1000,\
    phase:2,\
    chain,\
    log,\
    msg:\"Brute force attempt detected\""
    
SecRule IP:bf_counter "@gt 10" \
    "setvar:ip.bf_counter=+1,\
    exec:/usr/local/bin/block_ip.sh %{REMOTE_ADDR}"
' >> /etc/modsecurity.d/brute_force.conf

# Reiniciar Apache
sudo systemctl restart apache2
```

---

## 3. Defesa Contra SMB Enumeration & Password Spraying

### ❌ Problema Identificado

```
Protocolo: SMB (portas 139, 445)
Vulnerabilidades:
  1. Enumeração de usuários sem autenticação
  2. Sem proteção contra password spraying
  3. Protocolo NTLM sem salt adequado
```

---

### ✅ Solução 1: Desabilitar Enumeração Anônima

```bash
# Editar configuração Samba
sudo nano /etc/samba/smb.conf

# Adicionar/modificar na seção [global]:
# Não permitir null sessions (anônimas)
null passwords = no

# Não permitir enumeração de shares anônima
hosts allow = 192.168.1.0/24
# ou whitelist específica

# Desabilitar null shares
restrict anonymous = 2

# Reiniciar serviço
sudo systemctl restart smbd nmbd
```

### Impacto:
```bash
# Antes: Enumera usuários sem credenciais
nmap -p 139,445 --script smb-enum-users.nse 192.168.1.100
# User: backup, bin, daemon, ...

# Depois: Requer credenciais
# Falha em enumerar
```

---

### ✅ Solução 2: Account Lockout Policy

```bash
# Editar: /etc/samba/smb.conf

[global]
# Bloquear após 5 tentativas falhas
lockout threshold = 5

# Por 30 minutos
lockout duration = 1800

# Reset após 30 minutos sem tentativas
reset count minutes = 30

# Exigir senhas complexas
password must meet complexity requirements = yes

# Comprimento mínimo
minimum password length = 14
```

### Teste:
```bash
# Tentar login com senha errada 5 vezes
medusa -h 192.168.1.100 -u msfadmin -P /dev/null -M smbnt

# 6ª tentativa resultará em:
# ACCOUNT LOCKED
```

---

### ✅ Solução 3: Desabilitar SMBv1 (Inseguro)

```bash
# Editar: /etc/samba/smb.conf

[global]
# Requerer SMBv2 ou superior (SMBv3 é o melhor)
max protocol = SMB3
min protocol = SMB2_10

# Desabilitar versões antigas
smb 1 = no

# Reiniciar
sudo systemctl restart smbd
```

### Impacto:
```bash
# Antes: Vulnerável a ataques SMBv1 (EternalBlue, etc)
nmap --script smb-check-vulns.nse 192.168.1.100
# SMB1 detected

# Depois: Apenas SMBv2+
# Muito mais seguro
```

---

### ✅ Solução 4: Enable SMB Signing

```bash
# /etc/samba/smb.conf

[global]
# Exigir assinatura digital
server signing = required
client signing = required

# Usar Kerberos em vez de NTLM quando possível
use kerberos keytab = yes
ntlm auth = no  # Se o ambiente suportar Kerberos completo
```

---

### ✅ Solução 5: Monitoramento de Falhas SMB

```bash
# Instalar auditoria
sudo apt-get install auditd

# Adicionar regra de auditoria
echo '-w /var/log/samba/log.smbd -p wa -k samba_changes' | sudo tee -a /etc/audit/rules.d/audit.rules

sudo systemctl restart auditd

# Monitorar em tempo real
sudo tail -f /var/log/audit/audit.log | grep samba
```

### Análise de Logs:
```bash
# Ver tentativas de login SMB falhadas
grep -i "failed password" /var/log/samba/log.smbd | grep msfadmin

# Ver enumeração
grep -i "enumerate" /var/log/samba/log.smbd
```

---

### ✅ Solução 6: Usar Kerberos (Enterprise)

```bash
# Em ambiente corporativo, usar Active Directory + Kerberos
# ao invés de NTLM

# Setup (Samba como DC)
sudo apt-get install samba-provision-backend

# Provisionamento DC
sudo samba-tool domain provision

# Configurar SMBv3 + Kerberos apenas
# Elimina vulnerabilidades NTLM
```

---

## 4. Soluções Genéricas (Todas as Camadas)

### ✅ 1. Princípio do Menor Privilégio

```bash
# Executar serviços com usuários não-root
sudo useradd -r -s /bin/false ftpd

# Configurar propriedade
sudo chown ftpd:ftpd /var/ftp

# Alterar permissões
sudo chmod 750 /var/ftp
```

---

### ✅ 2. Firewall (iptables ou UFW)

```bash
# UFW (mais amigável)
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Permitir SSH (Kali -> Admin)
sudo ufw allow from 192.168.1.10 to any port 22

# Bloquear FTP por padrão (solução melhor = disable FTP)
# sudo ufw deny 21

# Permitir apenas internal networks para SMB
sudo ufw allow from 192.168.1.0/24 to any port 445

sudo ufw enable
```

---

### ✅ 3. VPN e Encriptação

```bash
# Usar VPN para administratores
# Usar TLS/SSL para todos os serviços

# Exemplo: SFTP ao invés de FTP
# OpenVPN para acesso remoto
sudo apt-get install openvpn

# Certificados SSL para HTTP
sudo apt-get install certbot python3-certbot-apache

# Renovação automática
sudo certbot renew --quiet
```

---

### ✅ 4. Auditoria e Logging

```bash
# Centralizar logs (ELK Stack, Splunk, etc)
sudo apt-get install rsyslog

# /etc/rsyslog.d/10-auth.conf
*.*;auth,authpriv.none  @siem.example.com:514

# Proteger logs (imutabilidade)
sudo apt-get install aide

# Criar baseline
sudo aideinit

# Verificar irregularidades
sudo aide --check
```

---

### ✅ 5. Hardening do SO

```bash
# Executar verificação de segurança
sudo apt-get install lynis

# Análise
sudo lynis audit system

# Aplicar recomendações:
# - Desabilitar serviços desnecessários
# - Atualizar kernel e pacotes
# - Configurar SELinux ou AppArmor
```

---

### ✅ 6. Política de Senhas Corporativa

| Aspecto | Recomendação |
|---------|-------------|
| **Comprimento Mínimo** | 14 caracteres |
| **Complexidade** | Maiúsculas, minúsculas, números, símbolos |
| **Validade** | 90 dias (políticas modernas: indefinido + MFA) |
| **Histórico** | Não reutilizar últimas 5 senhas |
| **Lockout** | 5 tentativas = 30 minutos bloqueado |
| **MFA** | Obrigatório em 2024+ |

---

### ✅ 7. Penetration Testing Regular

```bash
# Realizar testes periódicos (este laboratório!)
# Quarterly: Teste simples
# Annually: Teste completo
# Post-change: Sempre após atualizações críticas

# Usar frameworks
# NIST Cybersecurity Framework
# OWASP Testing Guide
# PTES (Penetration Testing Execution Standard)
```

---

## 5. Checklist de Implementação

### Defesa FTP
- [ ] FTP desabilizado OU rate limiting configurado
- [ ] Senhas fortes obrigatórias
- [ ] Account lockout após falhas
- [ ] Fail2ban instalado e ativo
- [ ] Logs monitorados

### Defesa Web
- [ ] Rate limiting em /login
- [ ] CAPTCHA após 3 falhas
- [ ] MFA implementado (TOTP ou similar)
- [ ] Account lockout policy
- [ ] WAF (ModSecurity) ativo
- [ ] HTTPS/TLS para todo o site

### Defesa SMB
- [ ] Enumeração anônima desabilida
- [ ] Account lockout policy (5 tentativas)
- [ ] SMBv1 desabilidado (v2.1+ obrigatório)
- [ ] SMB signing habilitado
- [ ] Logs auditados

### Geral
- [ ] Firewall (UFW) configurado
- [ ] Logging centralizado
- [ ] Senhas fortes (14+ caracteres)
- [ ] MFA para todas as contas críticas
- [ ] Atualizações de segurança aplicadas
- [ ] Penetration testing trimestral

---

## 📚 Referências de Compliance

| Framework | Aplica-se |
|-----------|-----------|
| **NIST SP 800-63** | Autenticação e Manejo de Identidades |
| **OWASP Top 10** | Segurança de Aplicações Web (A01:2021 - Broken Access Control) |
| **CIS Benchmarks** | Hardening de SO (hardening FTP, SMB) |
| **PCI-DSS** | Se armazena dados de cartão (MFA, Logging) |
| **GDPR** | Se usuários EU (Data Protection, Logs) |

---

**Última atualização:** 22 de março de 2026
