# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

git_name = %x(git config --get user.name).strip!
git_email = %x(git config --get user.email).strip!

$script = <<-SCRIPT
echo "- updating deb repository"
apt-get update > /dev/null

echo "- installing repository requirements"
export DEBIAN_FRONTEND=noninteractive
apt-get install -qq -y --force-yes build-essential git ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 ri1.9.1 rdoc1.9.1 libopenssl-ruby1.9.1 nginx gsl-bin libgsl0-dev > /dev/null

command -v nodejs > /dev/null || {
  echo "- installing nodejs requirements"
  apt-get install -qq -y --force-yes python-software-properties python g++ make > /dev/null
  add-apt-repository -y ppa:chris-lea/node.js > /dev/null
  apt-get update > /dev/null
  apt-get install -qq -y --force-yes nodejs > /dev/null
  npm install -g uglify-js clean-css > /dev/null
}

echo "- installing gem requirements"
cd /vagrant
echo "gem: --no-ri --no-rdoc" > ~/.gemrc
gem install bundler > /dev/null
bundle install > /dev/null

echo "- ensuring proper git config"
su - vagrant -c 'git config --global user.name "#{git_name}"'
su - vagrant -c 'git config --global user.email "#{git_email}"'

if [ ! -d /vagrant/source ]; then
  echo "- initial blog setup"
  rake setup
fi

if [ ! -d /vagrant/_site ]; then
  echo "- initial blog generation"
  rake generate > /dev/null
fi

echo "- setting up nginx"
cat > /etc/nginx/sites-available/default <<'EOF'
server {
  listen   4001;
  root /vagrant/_site;
  sendfile off;
  index index.html index.htm;
}
EOF

ps cax | grep 'nginx' > /dev/null
if [ $? -ne 0 ]; then service nginx start > /dev/null; fi
service nginx reload > /dev/null

if ! grep -q cd-to-directory "/home/vagrant/.bashrc"; then
  echo "- setting up auto chdir on ssh"
  echo "\n[ -n \\"\\$SSH_CONNECTION\\" ] && cd /vagrant # cd-to-directory" >> "/home/vagrant/.bashrc"
fi

echo -e "- blog is running! run further commands using:\n"
echo -e "    vagrant ssh -c 'cd /vagrant && rake COMMAND'\n"

echo -e "- to access the blog, please go to:\n"
echo "    rake serve (manually run): http://127.0.0.1:4000"
echo -e "    nginx (always on): http://127.0.0.1:4001\n"

echo -e "- if serving the app hangs, you may want to run:\n"
echo -e "    vagrant ssh -c 'cd /vagrant && pkill ruby 1.9.1'\n"

echo -e "- Available commands:\n"
rake -T 2>/dev/null | sed "s/^/    /"
SCRIPT


VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.network :forwarded_port, guest: 4000, host: 4000
  config.vm.network :forwarded_port, guest: 4001, host: 4001

  config.vm.provision :shell, inline: $script

  config.ssh.forward_agent = true

  config.vm.provider :vmware_fusion do |v, override|
    override.vm.box = "precise64_vmware_fusion"
    override.vm.box_url = "http://files.vagrantup.com/precise64_vmware_fusion.box"
  end
end
