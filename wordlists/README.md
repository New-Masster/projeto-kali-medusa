# 📋 Wordlists para Teste de Força Bruta

Esta pasta contém listas de senhas e usuários utilizadas nos testes de penetração.

---

## 📝 Arquivos

### `common-passwords.txt`
Lista de **senhas comuns** frequentemente utilizadas em sistemas vulneráveis.

**Características:**
- 46 senhas mais frequentes
- Inclui variações com maiúsculas/minúsculas
- Senhas com símbolos (!, @, #)
- Senhas padrão de sistemas (msfadmin, kali, test)

**Tamanho:** ~400 bytes
**Tempo de teste FTP:** ~30-60 segundos

**Casos de Uso:**
- Brute force em FTP
- Teste em formulários web (DVWA)
- Password spraying

### `users.txt`
Lista de **nomes de usuários** comuns em sistemas Linux/Windows.

**Características:**
- Usuários padrão do Metasploitable 2
- Usuários de sistema (bin, daemon, nobody)
- Usuários de aplicações (www-data, postgres, mysql)
- Usuários administrativos comuns

**Tamanho:** ~300 bytes
**Tempo de enumeração:** ~5-10 segundos

**Casos de Uso:**
- Enumeração SMB
- Password spraying

---

## 🔍 Como Usar

### Teste FTP
```bash
medusa -h 192.168.56.102 -u msfadmin -P wordlists/common-passwords.txt -M ftp
```

### Teste SMB (Password Spraying)
```bash
medusa -h 192.168.56.102 -U wordlists/users.txt -p password123 -M smbnt
```

### Teste DVWA
```bash
medusa -h 192.168.56.102 -u admin -P wordlists/common-passwords.txt -M web-form \
  -m FORM:/login.php \
  -m FORM-USERNAME:username \
  -m FORM-PASSWORD:password
```

### Teste com Hydra (Alternativa)
```bash
hydra -l msfadmin -P wordlists/common-passwords.txt ftp://192.168.56.102
```

---

## ⚠️ Licença e Uso

- **Uso:** Apenas em ambiente de laboratório/teste interno
- **Restrição:** Nunca usar em sistemas sem autorização
- **Responsabilidade:** Uso não autorizado é ilegal

---

## 📊 Estatísticas

| Wordlist | Entradas | Tamanho |
|----------|-----------|---------|
| common-passwords.txt | 46 | 400 B |
| users.txt | 36 | 300 B |

---

## 🔧 Criar Sua Própria Wordlist

### Método 1: Manualmente
```bash
# Criar arquivo
nano my-wordlist.txt

# Adicionar senhas (uma por linha)
password
123456
qwerty

# Usar
medusa -h TARGET -u USER -P my-wordlist.txt -M ftp
```

### Método 2: Usar Wordlists Profissionais
```bash
# Kali Linux já vem com wordlists
/usr/share/wordlists/

# Rockyou.txt (14M senhas)
/usr/share/wordlists/rockyou.txt.gz

# Decomprimir
gunzip /usr/share/wordlists/rockyou.txt.gz

# Usar
medusa -h 192.168.56.102 -u msfadmin -P /usr/share/wordlists/rockyou.txt -M ftp
```

### Método 3: Gerar Customizada
```bash
# Usando Crunch (gerar palavras-chave)
crunch 8 8 -t password% -o custom-list.txt
# Gera: password0, password1, ..., password9

# Usando CUPP (User Profile Based)
cupp -i
# Faz perguntas interativas
# Gera lista baseada em informações pessoais
```

---

## ⏱️ Performance

**Medusa (Online):**
- 10 senhas: ~30 segundos
- 100 senhas: ~5 minutos
- 1.000 senhas: ~50 minutos
- 10.000 senhas: ~8 horas

**Hashcat (Offline):**
- Mesmo volume: segundos
- 1M senhas: ~10-30 segundos

---

## 📚 Referências Externas

- [Kali Linux - Wordlists](https://tools.kali.org/password-attacks)
- [SecLists - GitHub](https://github.com/danielmiessler/SecLists)
- [Crunch - Wordlist Generator](https://tools.kali.org/password-attacks/crunch)
- [CeWL - Custom Wordlist](https://tools.kali.org/password-attacks/cewl)

---

**Última atualização:** 22 de março de 2026
