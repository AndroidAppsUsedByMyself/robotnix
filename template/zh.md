### **自编译 LineageOS 22.1 for pstar（基于 Nix）**  

---

### **I. 配置 Nix 环境**  
#### **方案选择（二选一）**  
**方案 A: 使用 Nix Docker（快速隔离环境）**  
```bash  
docker run -ti ghcr.io/nixos/nix  
```  

**方案 B: 本地安装 Nix**  
1. **启用 Flakes 和 nix-command（仅需一次）**  
   ```bash  
   # 在 /etc/nix/nix.conf 中添加以下内容  
   extra-experimental-features = flakes nix-command  
   ```  

---

### **II. 生成必要密钥**  
1. **生成密钥脚本（仅需一次，妥善保存密钥）**  
   ```bash  
   nix build github:AndroidAppsUsedByMyself/robotnix?dir=template#robotnixConfigurations.pstar_lineageos.generateKeysScript -o generate-keys  
   ./generate-keys ./keys  
   ```  

2. **移动密钥并设置权限**  
   ```bash  
   sudo cp -r keys /etc/secrets/android-keys  
   sudo chgrp -R nixbld /etc/secrets/android-keys  
   sudo chmod -R g+r /etc/secrets/android-keys  
   ```  

---

### **III. 配置编译缓存（CCache）**  
```bash  
sudo mkdir -p -m0770 /var/cache/ccache  
sudo chown root:nixbld /var/cache/ccache  
echo "max_size = 100G" | sudo tee /var/cache/ccache/ccache.conf  
```  
**提示**: 若内存不足，可调整 `zramswap` 配置以防止编译失败。  

---

### **IV. 构建 LineageOS 镜像**  
```bash  
nix build github:AndroidAppsUsedByMyself/robotnix?dir=template#robotnixConfigurations.pstar_lineageos.ota \  
  --option extra-sandbox-paths "/var/cache/ccache/=/var/cache/ccache/" \  
  --option extra-sandbox-paths "/keys=/etc/secrets/android-keys" \  
  -o lineageos_ota.zip  
```  

---

### **V. 系统迁移指南**  
#### **从官方 LineageOS 迁移到自编译版本**  
```bash  
wget https://raw.githubusercontent.com/AndroidAppsUsedByMyself/scripts/main/key-migration/migration.sh  
chmod +x ./migration.sh  
./migration.sh unofficial  
```  

#### **从自编译版本迁移回官方版本**  
```bash  
wget https://raw.githubusercontent.com/AndroidAppsUsedByMyself/scripts/main/key-migration/migration.sh  
chmod +x ./migration.sh  
./migration.sh official  
```  
**注意**: 脚本需在 `/data/local/tmp` 目录下以 Root 权限运行。  

---

### **附录：测试自编译版本**  
1. 若需测试自编译的 LineageOS，需执行密钥迁移：  
   ```bash  
   adb push migration.sh /data/local/tmp/  
   adb shell  
   cd /data/local/tmp  
   chmod +x migration.sh  
   ./migration.sh unofficial  # 切换到自编译版本  
   ./migration.sh official    # 切换回官方版本  
   ```  
**参考**: 密钥迁移脚本生成方法详见 [LineageOS Key Migration Guide](https://github.com/LineageOS/scripts/tree/main/key-migration).  

---

### **注意事项**  
1. **密钥安全**: 生成的 `/etc/secrets/android-keys` 需严格保密，避免泄露。  
2. **调试模式**: 若遇到 SELinux 权限问题（如 `avc: denied` 日志），检查是否为 `permissive` 模式，并在生产环境中修复策略。  
