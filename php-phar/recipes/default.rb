php_version = node[:php_phar][:version]
php_ext_dir = `php -r 'echo ini_get("extension_dir");'`.strip

execute "download PHP" do
  command "wget http://de2.php.net/get/php-#{php_version}.tar.gz/from/us.php.net/mirror -O /tmp/php-#{php_version}.tar.gz"
  not_if do
    File.directory?("/tmp/php-#{php_version}")
  end
end

execute "extract tar" do
  command "tar zxf php-#{php_version}.tar.gz"
  cwd     "/tmp"
  only_if do
    File.exists?("/tmp/php-#{php_version}.tar.gz")
  end
end

execute "build phar" do
  command "./configure --disable-all --enable-phar=shared && make"
  cwd     "/tmp/php-#{php_version}"
  not_if do
    File.exists?("/tmp/php-#{php_version}/modules/phar.so")
  end
end

execute "copy phar" do
  command "cp modules/phar.so /usr/local/lib/php/extensions/no-debug-non-zts-20090626/"
  cwd     "/tmp/php-#{php_version}"
  not_if do
    File.exists?("#{php_ext_dir}/phar.so")
  end
end

execute "add .ini to load ext/phar" do
  command "echo 'extension=phar.so' > /usr/local/etc/php/phar.ini"
end