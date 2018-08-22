namespace :setup do

  desc 'Cria um usuário admin: rake setup:admin\'[NOME,EMAIL,PASSWORD]\''
  task :admin, [:name, :email, :password] => :environment do |_task, args|
    # ARGV.each {|a| task a.to_sym do ; end}
    args_h = args.to_h
    if args_h.keys.size.zero?
      args_h = {
          name: 'Admin',
          email: 'admin@mcfox.com.br',
          password: 'Gordon@Mcfox'
      }
    end
    user = User.new(args_h)
    user.skip_confirmation! if user.respond_to?(:skip_confirmation!)
    user.skip_invitation = true if user.respond_to?(:skip_invitation)
    if user.save
      puts "Usuário foi criado com sucesso: #{user.email} #{args_h[:password]}"
    else
      puts "Erro ao tentar criar usuário:"
      puts "* " + user.errors.full_messages.join("\n* ")
    end
  end

end
