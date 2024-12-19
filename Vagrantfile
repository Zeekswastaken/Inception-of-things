Vagrant.configure("2") do |config|
    config.vm.box = "generic/alpine317"
    config.vm.network "forwarded_port", guest: 8080, host: 8080
    config.vm.provider "virtualbox" do |vrbox|
        vrbox.memory = 1024
        vrbox.cpus = 1
    end
    config.vm.define "zouazahrS" do |server|
        server.vm.hostname = "zouazahrS"
        server.vm.network "private_network", ip: "192.168.56.110"
        server.vm.synced_folder ".", "/vagrant"
        server.vm.provision "shell", privileged: true, path: "./scripts/server.sh", args:["192.168.56.110"]
    end
    config.vm.define "zouazahrWS" do |worker|
        worker.vm.hostname = "zouazahrwS"
        worker.vm.network "private_network", ip: "192.168.56.111"
        worker.vm.synced_folder ".", "/vagrant"
        worker.vm.provision "shell", privileged: true, path: "./scripts/worker.sh", args:["192.168.56.111", "192.168.56.110"]
    end
end
