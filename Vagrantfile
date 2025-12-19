Vagrant.configure("2") do |config|
  # استفاده از جعبه اوبونتو 22.04
  config.vm.box = "ubuntu/jammy64"
  config.vm.box_version = "20241002.0.0"
  
  # پیکربندی VirtualBox
  config.vm.provider "virtualbox" do |vb|
    vb.name = "TestDevOps_For_Vagrant"  # نامی که در VirtualBox می‌بینید
    vb.memory = "2048"  # 2GB RAM
    vb.cpus = 2         # 2 CPU core
  end
  
  # اجرای اسکریپت provision بعد از راه‌اندازی
  config.vm.provision "shell", path: "scripts/setup.sh"
  
  # انتقال پورت: دسترسی به وب‌سرور داخل VM از مک
  config.vm.network "forwarded_port", guest: 80, host: 8080
end
