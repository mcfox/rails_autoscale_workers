Devise.setup do |config|
  # The secret key used by Devise. Devise uses this key to generate
  # random tokens. Changing this key will render invalid all existing
  # confirmation, reset password and unlock tokens in the database.
  # Devise will use the `secret_key_base` as its `secret_key`
  # by default. You can change it below and use your own secret key.
  config.secret_key = 'dc604df7c7d9202151cdca4c24566c2e6d60a2cfcb6ca9dfa2c52dce51eb1ac062f54e16ac069bc86e19d60888f0be9747b7e05f8162aaf1f9884ffe09debd61'

  # ==> Mailer Configuration
  # Configure the e-mail address which will be shown in Devise::Mailer,
  # note that it will be overwritten if you use your own mailer class
  # with default "from" parameter.
  config.mailer_sender = 'notificacoes@mcfox.com.br'

  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  # require 'devise/orm/mongoid'
  require 'devise/orm/active_record'
end
