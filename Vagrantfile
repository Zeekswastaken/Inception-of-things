Vagrant.configure("2") do |config|
    config.vm.box = "generic/alpine317"
    
    config.vm.provider "virtualbox" do |vrbox|
        vrbox.memory = 1024
        vrbox.cpus = 1
    end
    config.vm.define "zouazahrS" do |server|
        server.vm.hostname = "zouazahrS"
        server.vm.network "private_network", ip: "192.168.56.110"
    end
    config.vm.define "zouazahrWS" do |worker|
        worker.vm.hostname = "zouazahrwS"
        worker.vm.network "private_network", ip: "192.168.56.111"
    end
end