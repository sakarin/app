/----------------------------------------------------------------------------------------------
/- ERROR - libmysqlclient.18.dylib For Development
/----------------------------------------------------------------------------------------------
sudo install_name_tool -change libmysqlclient.18.dylib /usr/local/mysql/lib/libmysqlclient.18.dylib /usr/local/rvm/gems/ruby-1.9.2-p290/gems/mysql2-0.2.13/lib/mysql2/mysql2.bundle




ActionController::Base.asset_host = "shop1:3000"

rake db:migrate RAILS_ENV="production"


# Config Mysql for Development
sudo ln -s /Applications/MAMP/tmp/mysql/mysql.sock /tmp/mysql.sock


# Clear Log
1. rake log:clear
2. service apache2 restart

/----------------------------------------------------------------------------------------------
/- spree-multi-currency
/----------------------------------------------------------------------------------------------
git://github.com/pronix/spree-multi-currency.git

bundle exec rake multi_currencies:install

The argument in square brackets is the iso code of your basic currency, so to load rates when US Dollar is your basic currency, use

->    rake multi_currencies:rates:google[usd]

if you want change rates GBP to main currency

1.  rake multi_currencies:rates:google[gbp]  RAILS_ENV="production"
2.  goto admin->configuration->currency setting-> set basic to gbp






