### **Self-Compiling LineageOS 22.1 for pstar (Using Nix)**  

---

### **I. Configure Nix Environment**  
#### **Options (Choose One)**  
**Option A: Use Nix Docker (Quick Isolation)**  
```bash  
docker run -ti ghcr.io/nixos/nix  
```  

**Option B: Local Nix Installation**  
1. **Enable Flakes and nix-command (One-Time Setup)**  
   ```bash  
   # Add the following to /etc/nix/nix.conf  
   extra-experimental-features = flakes nix-command  
   ```  

---

### **II. Generate Required Keys**  
1. **Generate Keys Script (One-Time, Save Securely)**  
   ```bash  
   nix build github:AndroidAppsUsedByMyself/robotnix?dir=template#robotnixConfigurations.pstar_lineageos.generateKeysScript -o generate-keys  
   ./generate-keys ./keys  
   ```  

2. **Move Keys and Set Permissions**  
   ```bash  
   sudo cp -r keys /etc/secrets/android-keys  
   sudo chgrp -R nixbld /etc/secrets/android-keys  
   sudo chmod -R g+r /etc/secrets/android-keys  
   ```  

---

### **III. Set Up CCache**  
```bash  
sudo mkdir -p -m0770 /var/cache/ccache  
sudo chown root:nixbld /var/cache/ccache  
echo "max_size = 100G" | sudo tee /var/cache/ccache/ccache.conf  
```  
**Tip**: Adjust `zramswap` if memory is insufficient to prevent build failures.  

---

### **IV. Build LineageOS Image**  
```bash  
nix build github:AndroidAppsUsedByMyself/robotnix?dir=template#robotnixConfigurations.pstar_lineageos.ota \  
  --option extra-sandbox-paths "/var/cache/ccache/=/var/cache/ccache/" \  
  --option extra-sandbox-paths "/keys=/etc/secrets/android-keys" \  
  -o lineageos_ota.zip  
```  

---

### **V. Migration Guide**  
#### **Migrate from Official to Self-Build**  
```bash  
wget https://raw.githubusercontent.com/AndroidAppsUsedByMyself/scripts/main/key-migration/migration.sh  
chmod +x ./migration.sh  
./migration.sh unofficial  
```  

#### **Migrate Back to Official Build**  
```bash  
wget https://raw.githubusercontent.com/AndroidAppsUsedByMyself/scripts/main/key-migration/migration.sh  
chmod +x ./migration.sh  
./migration.sh official  
```  
**Note**: Run the script in `/data/local/tmp` with root privileges.  

---

### **Appendix: Test Your Build**  
1. To test your self-compiled LineageOS, perform key migration:  
   ```bash  
   adb push migration.sh /data/local/tmp/  
   adb shell  
   cd /data/local/tmp  
   chmod +x migration.sh  
   ./migration.sh unofficial  # Switch to self-build  
   ./migration.sh official    # Revert to official  
   ```  
**Reference**: Key migration script generation details: [LineageOS Key Migration Guide](https://github.com/LineageOS/scripts/tree/main/key-migration).  

---

### **Important Notes**  
1. **Key Security**: Keep `/etc/secrets/android-keys` confidential to prevent leaks.  
2. **Debug Mode**: If SELinux denies permissions (e.g., `avc: denied` logs), check if in `permissive` mode and fix policies for production.  
