Vagrant.configure(2) do |config|

  config.vm.provider "virtualbox" do |vb|
     vb.gui = false
     vb.memory=8192
     vb.cpus=4
     vb.check_guest_additions=false
  end

  config.vm.box = "ubuntu/xenial64"
  config.vm.network "private_network", ip: "192.168.172.17"

  config.vm.network :forwarded_port, guest: 8080, host: 8080, auto_correct: true
  config.vm.network :forwarded_port, guest: 5050, host: 5050, auto_correct: true
  config.vm.network :forwarded_port, guest: 5051, host: 5051, auto_correct: true
  config.vm.network :forwarded_port, guest: 2181, host: 2181, auto_correct: true
  config.vm.network :forwarded_port, guest: 27017, host:27017, auto_correct: true
  config.vm.network :forwarded_port, guest: 8888, host: 8888, auto_correct: true
  config.vm.network :forwarded_port, guest: 9092, host: 9092, auto_correct: true
  config.vm.network :forwarded_port, guest: 7203, host: 7203, auto_correct: true
  config.vm.network :forwarded_port, guest: 3000, host: 3000, auto_correct: true
  config.vm.network :forwarded_port, guest: 3001, host: 3001, auto_correct: true
  config.vm.network :forwarded_port, guest: 3002, host: 3002, auto_correct: true
  config.vm.network :forwarded_port, guest: 3003, host: 3003, auto_correct: true
  config.vm.network :forwarded_port, guest: 9200, host: 9200, auto_correct: true
  config.vm.network :forwarded_port, guest: 9300, host: 9300, auto_correct: true
  config.vm.network :forwarded_port, guest: 5601, host: 5601, auto_correct: true
  config.vm.network :forwarded_port, guest: 31071, host: 31071, auto_correct: true

  for i in 31500..32000
      config.vm.network :forwarded_port, guest: i, host: i, auto_correct: false
  end


  config.vm.provision :shell, inline: "echo vm.max_map_count = 262144 >> /etc/sysctl.conf && sysctl -p"

  config.vm.provision "shell", path: "bootstrap.sh", keep_color: true

end
