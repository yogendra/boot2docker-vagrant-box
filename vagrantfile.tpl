# -*- mode: ruby -*-
# # vi: set ft=ruby :

Vagrant.require_version ">= 1.6.3"

Vagrant.configure("2") do |config|

  config.ssh.shell = "sh"
  config.ssh.username = "docker"
  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  ["vmware_fusion", "vmware_workstation"].each do |vmware|
    config.vm.provider vmware do |v|
      v.vmx["bios.bootOrder"]    = "CDROM,hdd"
      v.vmx["ide1:0.present"]    = "TRUE"
      v.vmx["ide1:0.fileName"]   = File.expand_path("../boot2docker.iso", __FILE__)
      v.vmx["ide1:0.deviceType"] = "cdrom-image"
      if v.respond_to?(:functional_hgfs=)
        v.functional_hgfs = false
      end
    end


  end
end
