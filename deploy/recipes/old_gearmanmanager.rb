app_dir = "#{base_dir}/vendor/GearmanManager"
etc_dir = "#{base_dir}/etc/gearman"

link "/usr/local/bin/gearman-manager" do
  to "#{app_dir}/#{node[:gearman_manager][:type]}-manager.php"
end

link "/etc/gearman-manager" do
  to etc_dir
end

link "/etc/init.d/gearman-manager" do
  to "#{base_dir}/bin/gearman-manager.initd"
end
