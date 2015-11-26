# ** PF FIREWALL ** #

PF(Packet Filter) firewall adalah fitur firewall pada FreeBSD yang merupakan bawaan dari sistem. Selain PF Firewall, terdapat 2 jenis firewall lain yaitu IPFW (IP Firewall) dan IPF (IP Filter). 
PF terdiri dari kernel-kernel packet filter dan sebuah userland utility untuk mengendalikan firewall secara fungsional.PF berorientasi terhadap terhadap objek. 

## Konfigurasi PF ##
### 1. Aktivasi PF Firewall ###

tambahkan line script berikut pada file /etc/rc.conf


```
#!conf

pf_enable="YES"
pf_rules="/etc/pf.conf" 
pflog_enable="YES"
pflog_file="YES"

```
### 2. Pembuatan Rule Firewall ###
**Rule firewall** adalah aturan untuk membatasi proses komunikasi data yang dibuat sesuai dengan kebutuhan. Sistem kerja awal dari PF adalah memblokir semua koneksi dan hanya melewatkan paket yang diijinkan. 

Berikut rule set yang digunakan untuk firewall ini :

* Block semua koneksi masuk dan keluar dari server
* Mengijinkan akses menuju repository update dari FreeBSD yaitu update.FreeBSD.org dan pkg.FreeBSD.org
* Mengijinkan akses dari dan menuju whitelist host yang ada dalam table private.
* Mengijinkan akses keluar masuk hanya pada port yang diijinkan yaitu port 80, 443, 9000, 22, 
* Mengijinkan koneksi ssh dengan maksimal koneksi 10 koneksi dari setiap single host
* Membatasi koneksi pada port 80, 443, 9000 dengan maksimal rate 500 koneksi per detik.
* Hanya mengijinkan icmp request dengan valid format 
* Membatasi jumlah koneksi tcp dan udp yaitu maksimal 10 koneksi dari setiap host dengan kecepatan maksimal 100 koneksi per 10 detik


### 3. Konfigurasi Firewall ###
tambahkan file [pf.conf](https://bitbucket.org/sysadmin-sandiloka/antiddos/src/pf.conf) pada folder /etc


### 4. Pembuatan Table untuk PF ###
Terdapat 3 table PF yang diperlukan untuk sistem firewall, yaitu :
* table fail2ban : berisi list ip address yang terdeteksi sebagai bruteforce ssh pada server
* table private : berisi list ip address yang diijinkan untuk terkoneksi kapanpun (white list) 
* table bad_host : berisi list ip address yang terdeteksi sebagai seorang DDoS attacker

Pada dasarnya, table akan terbentuk secara otomatis ketika kita melakukan restart PF. Yang perlu dibuat adalah file dari table tersebut. Berikut pembuatan file untuk table PF :

```
#!conf

# touch /etc/fail2ban 
# touch /etc/private 
# touch /etc/bad_host 
# chmod 755 /etc/fail2ban 
# chmod 755 /etc/private 
# chmod 755 /etc/bad_host
```

### 5. Check file konfigurasi dari error tanpa harus me-load konfigurasi ###

```
#!conf

# pfctl -vnf /etc/pf.conf
```

### 6. Load File Konfigurasi ###
Jika file konfigurasi sudah benar, load file konfigurasi /etc/pf.conf yang sudah disetting agar sistem dapat membaca firewall

```
#!conf

# pfctl -e
# pfctl -f /etc/pf.conf
```

### 7. Restart service PF  ###

```
#!conf

# service pf restart
```