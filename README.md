# DevOps_Steps
A brilliant set for starting the DevOps Engineering steps.

# Vagrant Setup Journey: From Zero to Working VM

## 📋 **Project Overview**
This document captures the complete journey of setting up a Vagrant-managed Ubuntu 22.04 virtual machine on a Mac running VMware Fusion with an intermediate Ubuntu Server VM. This setup demonstrates **nested virtualization** and solves multiple real-world challenges.

## 🎯 **What We Accomplished**
Successfully created a three-layer virtualization environment:
1. **Mac host** → VMware Fusion → Ubuntu Server VM
2. **Ubuntu Server** → VirtualBox (via Vagrant) → Ubuntu 22.04 VM
3. **Fully functional** development environment with SSH access

---

## 📝 **Step-by-Step Journey**

### **Phase 1: Initial Setup & Challenges**
- **Goal**: Copy/paste commands from Mac browser into Ubuntu Server VM terminal
- **Solution**: Use SSH instead of VMware clipboard (most reliable method)
- **Key Learning**: `ssh username@vm-ip` gives native Mac copy/paste functionality

### **Phase 2: Installing HashiCorp Tools**
- **Challenge**: `apt-key` deprecation warning when adding HashiCorp repository
- **Solution**: Modern key management approach:
  ```bash
  # Download and save GPG key properly
  wget -O- https://keybase.io/hashicorp/pgp_keys.asc | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  
  # Add repository with signed-by directive
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com jammy main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  ```

### **Phase 3: Vagrant Box Setup**
- **Challenge**: `bento/ubuntu-22.04` box returns 404 error
- **Discovery**: Bento project no longer hosts boxes on Vagrant Cloud
- **Solution**: Use official Ubuntu boxes instead:
  ```bash
  # Working box alternatives:
  vagrant box add ubuntu/jammy64        # Official Ubuntu 22.04
  vagrant box add generic/ubuntu2204    # Popular community alternative
  ```

### **Phase 4: Provider Configuration**
- **Challenge**: Vagrant automatically selects libvirt provider on Linux
- **Solution**: Explicitly specify VirtualBox provider:
  ```bash
  vagrant up --provider virtualbox
  ```
- **Alternative**: Configure in Vagrantfile:
  ```ruby
  config.vm.provider "virtualbox"
  ```

### **Phase 5: VirtualBox Installation & Nested Virtualization**
- **Challenge**: `VT-x is not available (VERR_VMX_NO_VMX)` error
- **Root Cause**: Nested virtualization disabled in VMware settings
- **Solution**: Enable hypervisor support in VMware Fusion VM settings

### **Phase 6: SSH Timeout Resolution**
- **Symptom**: Vagrant times out waiting for SSH connection
- **Discovery**: VM was actually booting successfully
- **Workaround**: Manual SSH connection revealed VM was working:
  ```bash
  ssh vagrant@127.0.0.1 -p 2222 -i ~/.vagrant.d/insecure_private_key
  ```
- **Final State**: Successful connection with prompt `vagrant@ubuntu-jammy:~$`

---

## 🛠️ **Key Technical Solutions**

### **1. Nested Virtualization Setup**
```bash
# Install VirtualBox in intermediate VM
sudo apt install virtualbox

# Load kernel modules
sudo modprobe vboxdrv vboxnetflt vboxnetadp

# Add user to vboxusers group
sudo usermod -a -G vboxusers $USER
# Then log out and back in
```

### **2. Vagrant Project Structure**
```
~/my-vagrant-project/
├── Vagrantfile          # VM configuration
└── (project files)
```

### **3. Essential Vagrant Commands**
```bash
# Initialize new project
vagrant init ubuntu/jammy64

# Start VM with specific provider
vagrant up --provider virtualbox

# Connect to VM
vagrant ssh

# Manage VM state
vagrant halt      # Stop
vagrant suspend   # Pause
vagrant destroy   # Delete
vagrant reload    # Restart with new config
```

---

## 💡 **Critical Lessons Learned**

### **1. Box Selection Strategy**
- **Avoid deprecated boxes**: Bento project boxes are no longer maintained
- **Prefer official sources**: `ubuntu/jammy64` from Canonical is reliable
- **Check provider compatibility**: Not all boxes support all providers

### **2. Provider Management**
- **Linux defaults to libvirt**: Explicitly specify `--provider virtualbox`
- **VMware requires plugin**: `vagrant plugin install vagrant-vmware-desktop` (paid)
- **Provider configuration permanence**: Set in Vagrantfile to avoid repeating flags

### **3. Nested Virtualization Considerations**
- **Performance impact**: VM inside VM has noticeable overhead
- **Enable VT-x/AMD-V**: Required in outer hypervisor (VMware) settings
- **Alternative approach**: libvirt/KVM often works better for Linux-on-Linux

### **4. SSH Connectivity**
- **First boot patience**: Ubuntu boxes can take several minutes first time
- **Manual SSH test**: Direct SSH connection verifies VM is actually running
- **Key management**: Vagrant uses `~/.vagrant.d/insecure_private_key` by default

---

## 🚀 **Production-Ready Vagrantfile Template**

```ruby
Vagrant.configure("2") do |config|
  # Base box (Ubuntu 22.04 LTS)
  config.vm.box = "ubuntu/jammy64"
  
  # Provider configuration
  config.vm.provider "virtualbox" do |vb|
    vb.name = "project-vm"
    vb.memory = "2048"
    vb.cpus = 2
    vb.gui = false  # Set to true for debugging
  end
  
  # Network configuration
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "private_network", ip: "192.168.33.10"
  
  # Synced folders
  config.vm.synced_folder "./src", "/var/www/html"
  
  # Provisioning (first-time setup)
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get upgrade -y
    apt-get install -y python3 nodejs nginx
    # Your setup commands here
  SHELL
  
  # Boot timeout (increase for slow systems)
  config.vm.boot_timeout = 300
end
```

---

## 🔧 **Troubleshooting Quick Reference**

| Problem | Solution |
|---------|----------|
| **`apt-key` deprecated warning** | Use `signed-by` directive with GPG key in `/usr/share/keyrings/` |
| **Box 404 error** | Switch to official box like `ubuntu/jammy64` |
| **Provider not found** | Install provider plugin or use `--provider` flag |
| **VT-x not available** | Enable nested virtualization in VMware settings |
| **SSH timeout** | Increase `config.vm.boot_timeout`, try manual SSH |
| **Synced folder errors** | Set `VAGRANT_DISABLE_VBOXSYMLINKCREATE=1` environment variable |

---

## 📚 **Resources & References**

1. **Vagrant Documentation**: https://www.vagrantup.com/docs
2. **Ubuntu Cloud Images**: https://cloud-images.ubuntu.com/
3. **VirtualBox Nested Virtualization**: https://www.virtualbox.org/manual/ch09.html#nested-virt
4. **HashiCorp Repository Setup**: https://www.hashicorp.com/official-packaging-guide

---

## 🎉 **Success Metrics**
- ✅ Multi-layer virtualization environment operational
- ✅ Automated VM provisioning with Vagrant
- ✅ SSH connectivity established
- ✅ Development environment isolated and reproducible
- ✅ All components version-controlled via Vagrantfile

---

*This journey demonstrates that with persistence and systematic troubleshooting, even complex nested virtualization setups can be made to work reliably. The key is understanding each layer of the stack and methodically verifying each component.*

**Timestamp**: December 12, 2025  
**Environment**: Mac → VMware Fusion → Ubuntu Server 22.04 → Vagrant → Ubuntu 22.04 VM
